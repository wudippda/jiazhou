class ReportController < ApplicationController

  CUSTOMER_LIST_SHEET_NAME = "Customer List".downcase
  PROPERTY_INCOME_SHEET_NAME_PREFIX = "Property".downcase
  PROPERTY_OWNER_NAME_LABEL = 'PROPERTY OWNER'
  PROPERTY_OWNER_EMAIL_LABEL = 'OWNER EMAIL'
  PROPERTY_OWNER_PHONE_LABEL = 'OWNER PHONE#'
  PROPERTY_ADDRESS_LABEL = 'PROPERTY ADDRESS'
  PROPERTY_LOT_LABEL = 'LOT'
  TENANT_EMAIL_LABEL = 'TENANT EMAIL'
  TENANT_NAME_LABEL = 'TENANT(S)'
  TENANT_PHONE_LABEL = 'TENANT PHONE#'
  EXPIRE_DATE_LABEL = 'LEASE EXPIRE DATE'
  EMPTY_VALUE = ''
  MONTH_COUNT_FOR_ONE_YEAR = 12
  EXPENSE_COST_FORMAT_STRING = '%.2f'
  MONTH_INCOME_OTHER_CATEGORY_LABEL = 'Other'.downcase

  class ReportParsingException < StandardError
  end

  def encode(str)
    return ApplicationHelper.forceToDefaultEncoding(str)
  end

  def readValue(value)
    return encode(value.to_s || EMPTY_VALUE).strip
  end

  def send_report
    @user = User.find(params[:id])
    @reportType = params[:report_type] || "full"

    if @user
      #@report = generate_report(@user, @report_type)
      MonthlyReportMailer.with(receiver: @user).send_monthly_report_email.deliver_now
    end

    render json: {res: true}
  end

  def parse_customer_list_by_row(rowData)
    # User fields
    ownerEmail = rowData[PROPERTY_OWNER_EMAIL_LABEL]
    ownerPhoneNumber = rowData[PROPERTY_OWNER_PHONE_LABEL]
    ownerName = rowData[PROPERTY_OWNER_NAME_LABEL]

    # Property fields
    propertyAddress = rowData[PROPERTY_ADDRESS_LABEL]
    propertyLot = rowData[PROPERTY_LOT_LABEL]

    # Tenant fields
    tenantEmail = encode(rowData[TENANT_EMAIL_LABEL].gsub(/\s+/, "").strip)
    tenantPhone = rowData[TENANT_PHONE_LABEL]
    tenantName = rowData[TENANT_NAME_LABEL]

    # Others
    expireDate = rowData[EXPIRE_DATE_LABEL]

    return {email: ownerEmail, phone_number: ownerPhoneNumber, name: ownerName}, #owner fields
           {address: propertyAddress, lot: propertyLot},                         #property fields
           {tenant_email: tenantEmail, tenant_name: tenantName, tenant_phone: tenantPhone}, #tenant fields
           {expire_date: expireDate}                                             #renting contract fields
  end

  def validate_customer_list_by_row(userFields, propertyFields, tenantFields, contractFields)
    user = User.new(userFields)
    property = user.properties.new(propertyFields)
    tenant = user.tenants.new(tenantFields)

    validationRes = false
    errors = Array.new

    if user.valid? && property.valid? && tenant.valid?
      validationRes = true
    else
      errors << user.errors.messages
      errors << property.errors.messages
      errors << tenant.errors.messages
    end

    return validationRes, errors
  end

  def parse_customer_list(customerSheet)
    customerSheetData = customerSheet.sheet_data
    customerListRes = Array.new
    if customerSheetData && customerSheetData[0]
      tableColSize = customerSheetData[0].cells.size
      # Read table headers
      tableHeaders = Array.new
      customerSheetData[0].cells.each do |header|
        value = header && header.value.strip.try(:upcase)
        tableHeaders << value
      end
      Rails.logger.debug("Table headers: #{tableHeaders}")

      # Row index, start from 1 to skip header row
      tableRowIdx = 1
      while customerSheetData[tableRowIdx]
        rowData = Hash.new
        nonEmpty = false
        tableColSize.times do |idx|
          value = customerSheetData[tableRowIdx][idx].value if customerSheetData[tableRowIdx][idx]
          rowData[tableHeaders[idx]] = readValue(value || EMPTY_VALUE)
          nonEmpty = true if nonEmpty || value
        end
        if nonEmpty
          Rails.logger.debug("Row data: #{rowData.to_s}")
          userFields, propertyFields, tenantFields, contractFields = parse_customer_list_by_row(rowData)
          validateRes, errors =  validate_customer_list_by_row(userFields, propertyFields, tenantFields, contractFields)
          if validateRes
            customerListRes << {userFields: userFields, propertyFields: propertyFields, tenantFields: tenantFields, contractFields: contractFields}
          else
            Rails.logger.info(errors)
            raise ReportParsingException.new("Parsing error for sheet #{customerSheet.sheet_name} at line (#{tableRowIdx + 1}): #{errors.reject!{|error| error.empty?}.to_s}")
          end
        end
        tableRowIdx += 1
      end
    end
    return customerListRes
  end

  def diff_attrs_updates(attrs, updates)
    res = Hash.new
    updates.keys.each do |key|
      if attrs.key?(key) && updates[key] != attrs[key]
        res[key] = updates[key]
      end
    end
    return res
  end

  def persist_customer_list_data(customerList)
    customerList.each do |row|
      userFields = row[:userFields]
      propertyFields = row[:propertyFields]
      tenantFields = row[:tenantFields]
      contractFields = row[:contractFields]

      user = User.where(email: userFields[:email]).first_or_create!(userFields)
      userUpdates = diff_attrs_updates(user.attributes, userFields)
      user.update(userUpdates) if !userUpdates.empty?

      tenant = user.tenants.where(tenant_email: tenantFields[:tenant_email]).first_or_create!(tenantFields)
      tenantUpdates = diff_attrs_updates(tenant.attributes, tenantFields)
      tenant.update(tenantUpdates) if !tenantUpdates.empty?

      property = user.properties.where(address: propertyFields[:address], lot: propertyFields[:lot]).first_or_create!(propertyFields)
      propertyUpdates = diff_attrs_updates(property.attributes, propertyFields)
      tenant.update(propertyUpdates) if !propertyUpdates.empty?

      expireDate = contractFields[:expire_date]
      user.renting_contracts.where(tenant_id: tenant.id).update(property_id: property.id, expire_date: DateTime.strptime(expireDate))
    end
  end

  def persist_monthly_report_data(monthlyReportList)
    #{propertyOwner: propertyOwner, propertyAddress: propertyAddress, expenses: expenses}
    monthlyReportList.each do |row|
      propertyOwner = row[:propertyOwner]
      propertyAddress = row[:propertyAddress]
      expenses = row[:expenses]

      Property.where(address: propertyAddress).each do |property|
        if property.user.name.downcase == propertyOwner.downcase
            expenses.each do |expense|
              e = property.expenses.where(date: expense[:date], is_cost: expense[:is_cost],
                                      category: expense[:category]).first_or_create!(expense.merge({property_id: property.id}))
              e.update(cost: expense[:cost]) if e.cost != expense[:cost]
            end
          break
        end
      end
    end
  end

  def findIndexByAnchor(dataSheet, anchor, r = -1, c = -1, mode = 1)
    if r != -1 && c != -1
      if dataSheet[r] && dataSheet[r][c]
        return [r, c] if matchAnchor(readValue(dataSheet[r][c].value), anchor, mode)
      end
    end

    rowLimit = (r != -1 ? [r, dataSheet.size].min : dataSheet.size)
    rowLimit.times do |idx|
      colLimit = (c != -1 ? [c, dataSheet[idx].cells.size].min : dataSheet[idx].cells.size)
      (colLimit + 1).times do |idy|
        return [idx, idy] if matchAnchor(readValue(dataSheet[idx][idy].value), anchor, mode)
      end
    end
    return [-1, -1]
  end

  def matchAnchor(value, anchor, mode)
    case mode
    when 1 #start_with
      return true if value.downcase.start_with?(anchor)
    when 2 #index
      return true if value.downcase.index(anchor) != -1
    end
    return false
  end

  def costToDecimal(costStr)
    format(EXPENSE_COST_FORMAT_STRING, costStr.gsub('$', ''))
  end

  def parse_single_row_expense(row, taxYear, category, isCost)
    resArray = Array.new
    MONTH_COUNT_FOR_ONE_YEAR.times do |idx|
      raise ReportParsingException.new("Parsing error! Expense missed for category #{row[0]} at column #{idx + 1}") if row[idx + 1].nil?
      date = DateTime.strptime("#{idx + 1}/#{taxYear}", ApplicationHelper::EXPENSE_DATE_FORMAT_STRING)
      resArray << {
          date: date,
          is_cost: isCost,
          cost: costToDecimal(readValue(row[idx + 2].value)),
          category: category
      }
    end
    return resArray
  end

  def get_index_by_rule(monthlyDataSheet, rule)
    index = findIndexByAnchor(monthlyDataSheet, rule[:anchorText].downcase, rule[:rowIndex], rule[:colIndex])
    raise ReportParsingException.new("No anchor found within the given index! Rule: #{rule[:description]}") if index == [-1, -1]
    return index
  end

  def read_value_by_rule(monthlyDataSheet, rule, index)
    if rule[:valuePos]
      x = rule[:valuePos][:x] || 0
      if monthlyDataSheet[index[0] + x]
        y = rule[:valuePos][:y] || 0
        return readValue(monthlyDataSheet[index[0] + x][index[1] + y].value) if monthlyDataSheet[index[0] + x][index[1] + y]
      end
    end
    raise ReportParsingException.new("Parsing error! Can not read value by rule #{rule[:description]}")
  end

  def parse_monthly_report(monthlySheet)
    monthlySheetData = monthlySheet.sheet_data
    expenses = Array.new
    rules = ReportHelper.get_excel_rules
    raise ReportParsingException.new("Parsing error! No parsing rule file found with filename #{ReportHelper::EXCEL_PARSING_RULES_FILENAME}") if rules.nil?

    taxYearRule = rules[:taxYearRule]
    taxYearIndex = get_index_by_rule(monthlySheetData, taxYearRule)
    taxYear = read_value_by_rule(monthlySheetData, taxYearRule, taxYearIndex).gsub(/\D/, EMPTY_VALUE)

    propertyOwnerRule = rules[:propertyOwnerRule]
    propertyOwnerIndex = get_index_by_rule(monthlySheetData, propertyOwnerRule)
    propertyOwner = read_value_by_rule(monthlySheetData, propertyOwnerRule, propertyOwnerIndex)

    propertyAddressRule = rules[:propertyAddressRule]
    propertyAddressIndex = get_index_by_rule(monthlySheetData, propertyAddressRule)
    propertyAddress = read_value_by_rule(monthlySheetData, propertyAddressRule, propertyAddressIndex).gsub(/^[0-9]*\)\s+/, EMPTY_VALUE)

    expenseStartRule = rules[:expenseStartRule]
    expenseStartIndex = get_index_by_rule(monthlySheetData, expenseStartRule)

    expenseStopRule = rules[:expenseStopRule]
    expenseStopIndex = get_index_by_rule(monthlySheetData, expenseStopRule)

    incomeRule = rules[:incomeRule]
    incomeIndex = get_index_by_rule(monthlySheetData, incomeRule)
    incomeCategory = read_value_by_rule(monthlySheetData, incomeRule, incomeIndex)

    Rails.logger.debug("Tax Year pos: #{taxYearIndex}, Owner pos: #{propertyOwnerIndex}, Address pos: #{propertyAddressIndex}")
    Rails.logger.debug("Tax Year: #{taxYear}, Owner: #{propertyOwner}, Address: #{propertyAddress}")
    Rails.logger.debug("Income pos: #{incomeIndex}, Expense start pos: #{expenseStartIndex}, Expense stop pos: #{expenseStopIndex}")

    # Read incoming expenses
    incomingExpenses = parse_single_row_expense(monthlySheetData[incomeIndex[0]], taxYear, incomeCategory,false)
    Rails.logger.info("IncomingExpense size: #{incomingExpenses.size}")
    Rails.logger.info("IncomingExpense: #{incomingExpenses}")
    incomingExpenses.each { |expenseData| expenses << expenseData }

    # Read outgoing expenses
    otherCategoryCount = 1
    (expenseStartIndex[0] + 1..expenseStopIndex[0] - 1).each do |rowIndex|
      category = readValue(monthlySheetData[rowIndex][0].value)
      if category.downcase == MONTH_INCOME_OTHER_CATEGORY_LABEL
        category += otherCategoryCount.to_s
        otherCategoryCount += 1
      end
      outgoingExpenses = parse_single_row_expense(monthlySheetData[rowIndex], taxYear, category,true)
      outgoingExpenses.each { |expenseData| expenses << expenseData }
    end
    Rails.logger.info("expenses size: #{expenses.size}")
    Rails.logger.info("expenses: #{expenses}")
    return {propertyOwner: propertyOwner, propertyAddress: propertyAddress, expenses: expenses}
  end

  def get_archived_reports(archivedFile, extractDirectory)
    files = Array.new
    Zip::File.open(archivedFile) do |zip_file|
      zip_file.glob("[^_]*.{#{ReportUploader::EXCEL_EXTENSIONS.join(',')}}", File::FNM_EXTGLOB).each do |entry|
        filePath = File.join(extractDirectory, entry.name)
        entry.extract(filePath) unless File.exist?(filePath)
        files << filePath
      end
    end
    return files
  end

  def parse_report
    respondJson = {}
    parseSuccess = false
    report = HousingReport.find_by(id: params[:id])

    if report && report.report.file
      begin
        raise ReportParsingException.new('Report already parsed!') if report.parsed
        extension = File.extname(report.original_filename).delete('.')
        reportsToParse = Array.new
        fileDirectory = File.dirname(report.report.current_path)
        extractDirectory = File.join(fileDirectory, SecureRandom.hex)

        if ReportUploader::ARCHIVE_EXTENSIONS.include?(extension)
          FileUtils.mkdir_p(extractDirectory)
          reportsToParse += get_archived_reports(report.report.current_path, extractDirectory)
          #FileUtils.rm_rf(extractDirectory)
        elsif ReportUploader::EXCEL_EXTENSIONS.include?(extension)
          reportsToParse << report.report.current_path
        end
        Rails.logger.debug(reportsToParse)

        customerList = Array.new
        monthlyReportList = Array.new
        successReport = Array.new

        reportsToParse.each_with_index do |r, idx|
          Rails.logger.info("Parsing report #{idx + 1} out of #{reportsToParse.size}")
          workbook = RubyXL::Parser.parse(r)
          workbook.worksheets.each do |sheet|
            sheetName = sheet.sheet_name.strip.downcase
            if sheetName == CUSTOMER_LIST_SHEET_NAME
              customerList += parse_customer_list(sheet)
            elsif sheetName.start_with?(PROPERTY_INCOME_SHEET_NAME_PREFIX)
              monthlyReportList << parse_monthly_report(sheet)
            end
          end
          successReport << File.basename(r)
        end
        Rails.logger.debug("Parsed customer list: #{customerList}")
        Rails.logger.debug("Parsed monthly report list: #{monthlyReportList}")
        Rails.logger.debug("Suceeded parsing list: #{successReport}")

        ActiveRecord::Base.transaction do
          persist_customer_list_data(customerList) if !customerList.empty?
          persist_monthly_report_data(monthlyReportList) if !monthlyReportList.empty?
        end

      # if parsing process succeed
      report.update(parsed: true)
      respondJson['parseSuccess'] = true

      rescue ReportParsingException => e
        Rails.logger.error("ReportParsingException raised! #{e.to_s}")
        respondJson['parseSuccess'] = false
        respondJson['errorMsg'] = e.message
      ensure
        if extractDirectory && extractDirectory.start_with?(fileDirectory)
          FileUtils.rm_rf(extractDirectory)
          Rails.logger.debug("Temp extracted directory removed at #{extractDirectory}")
        end
      end
    else
      respondJson[:error] = "Report with id #{params[:id]} not found!"
    end
    render json: respondJson
  end
end