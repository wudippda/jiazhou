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
  MONTH_INCOME_WORKSHEET_START_COL = 0
  MONTH_INCOME_OTHERA_CATEGORY_LABEL = 'Other'.downcase
  MONTH_INCOME_TAX_YEAR_ANCHOR = 'Tax Year:'.downcase
  MONTH_INCOME_ANCHOR = 'Income'.downcase
  MONTH_INCOME_PROPERTY_OWNER_ANCHOR = 'Rental Property Income Expense Statement For:'.downcase
  MONYH_INCOME_PROPERTY_ADDRESS_ANCHOR = 'Property Address:'.downcase
  EXPENSE_OUTGOING_START_ANCHOR = 'Expenses'.downcase
  EXPENSE_OUTGOING_STOP_ANCHOR = 'Total Expenses'.downcase

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
      UserMailer.with(receiver: @user).incoming_email.deliver_now
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

  def parse_customer_list(customerSheetData)
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
            raise ReportParsingException.new("Parsing error at line (#{tableRowIdx + 1}): #{errors.reject!{|error| error.empty?}.to_s}")
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

      ActiveRecord::Base.transaction do
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
  end

  def persist_monthly_report_data(monthlyReportList)
    #{propertyOwner: propertyOwner, propertyAddress: propertyAddress, expenses: expenses}
    ActiveRecord::Base.transaction do
      monthlyReportList.each do |row|
        propertyOwner = row[:propertyOwner]
        propertyAddress = row[:propertyAddress]
        expenses = row[:expenses]

        Property.where(address: propertyAddress).each do |property|
          if property.user.name.downcase == propertyOwner.downcase
              expenses.each do |expense|
                expense[:property_id] = property.id
                Expense.new(expense).save!
              end
            break
          end
        end
      end
    end
  end

  def findIndexByAnchor(dataSheet, anchor, x = -1, y = -1, mode = 1)
    if x != -1 && y != -1
      if dataSheet[x] && dataSheet[x][y]
        return [x, y] if matchAnchor(readValue(dataSheet[x][y].value), anchor, mode)
      end
    end
    return [x, findIndexByAnchorX(dataSheet, anchor, x, mode)] if x != -1
    return [findIndexByAnchorY(dataSheet, anchor, y, mode), y] if y != -1
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

  def findIndexByAnchorX(dataSheet, anchor, xIndex, mode)
    return -1 if dataSheet[xIndex].nil?
    dataSheet[xIndex].cells.size.times do |yIndex|
      value = readValue(dataSheet[xIndex][yIndex].value)
      return yIndex if matchAnchor(value, anchor, mode)
    end
    return -1
  end

  def findIndexByAnchorY(dataSheet, anchor, yIndex, mode)
    dataSheet.size.times do |xIndex|
      next if dataSheet[xIndex][yIndex].nil?
      value = readValue(dataSheet[xIndex][yIndex].value)
      return xIndex if matchAnchor(value, anchor, mode)
    end
    return -1
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

  def parse_monthly_report(monthlyDataSheet)
    expenses = Array.new

    if monthlyDataSheet
      taxYearIndex = findIndexByAnchor(monthlyDataSheet, MONTH_INCOME_TAX_YEAR_ANCHOR, -1, MONTH_INCOME_WORKSHEET_START_COL)
      taxYear = readValue(monthlyDataSheet[taxYearIndex[0]][MONTH_INCOME_WORKSHEET_START_COL].value).gsub(/\D/, EMPTY_VALUE) if taxYearIndex[0] != -1

      propertyOwnerIndex = findIndexByAnchor(monthlyDataSheet, MONTH_INCOME_PROPERTY_OWNER_ANCHOR, -1, MONTH_INCOME_WORKSHEET_START_COL)
      propertyOwner = EMPTY_VALUE
      if propertyOwnerIndex[0] != -1 && monthlyDataSheet[propertyOwnerIndex[0] + 1] && monthlyDataSheet[propertyOwnerIndex[0] + 1][MONTH_INCOME_WORKSHEET_START_COL]
        propertyOwner = readValue(monthlyDataSheet[propertyOwnerIndex[0] + 1][MONTH_INCOME_WORKSHEET_START_COL].value)
      end

      propertyAddressIndex = findIndexByAnchor(monthlyDataSheet, MONYH_INCOME_PROPERTY_ADDRESS_ANCHOR, -1, MONTH_INCOME_WORKSHEET_START_COL)
      propertyAddress = EMPTY_VALUE
      if propertyAddressIndex[0] != -1 && monthlyDataSheet[propertyAddressIndex[0] + 1] && monthlyDataSheet[propertyAddressIndex[0] + 1][MONTH_INCOME_WORKSHEET_START_COL]
        propertyAddress = readValue(monthlyDataSheet[propertyAddressIndex[0] + 1][MONTH_INCOME_WORKSHEET_START_COL].value).gsub(/^[0-9]*\)\s+/,EMPTY_VALUE)
      end

      Rails.logger.debug("Tax Year pos: #{taxYearIndex}, Owner pos: #{propertyOwnerIndex}, Address pos: #{propertyAddressIndex}")
      Rails.logger.debug("Tax Year: #{taxYear}, Owner: #{propertyOwner}, Address: #{propertyAddress}")

      # Read incoming expenses
      incomingExpensesAnchor = findIndexByAnchor(monthlyDataSheet, MONTH_INCOME_ANCHOR, -1, MONTH_INCOME_WORKSHEET_START_COL)
      if incomingExpensesAnchor[0] != -1
        if !monthlyDataSheet[incomingExpensesAnchor[0]].nil?
          category = readValue(monthlyDataSheet[incomingExpensesAnchor[0]][0].value)
          incomingExpenses = parse_single_row_expense(monthlyDataSheet[incomingExpensesAnchor[0]], taxYear, category,false)
          incomingExpenses.each do |expenseData|
            #Rails.logger.debug("Incoming Expense Data: #{expenseData}")
            expenses << expenseData
          end
        end
      else
        Rails.logger.info("#{MONTH_INCOME_ANCHOR} ANCHOR not found!");
      end

      # Read outgoing expenses
      expenseStartIndex = findIndexByAnchor(monthlyDataSheet, EXPENSE_OUTGOING_START_ANCHOR, -1, MONTH_INCOME_WORKSHEET_START_COL)
      expenseStopIndex = findIndexByAnchor(monthlyDataSheet, EXPENSE_OUTGOING_STOP_ANCHOR, -1, MONTH_INCOME_WORKSHEET_START_COL)

      Rails.logger.debug("Expense start pos: #{expenseStartIndex}, Expense stop pos: #{expenseStopIndex}")

      otherCategoryCount = 1
      if expenseStartIndex[0] != -1 && expenseStopIndex[0] != -1
        (expenseStartIndex[0] + 1..expenseStopIndex[0] - 1).each do |rowIndex|
          if !monthlyDataSheet[rowIndex].nil?
            category = readValue(monthlyDataSheet[rowIndex][0].value)
           if category.downcase == MONTH_INCOME_OTHERA_CATEGORY_LABEL
             category += otherCategoryCount.to_s
             otherCategoryCount += 1
           end
            outgoingExpenses = parse_single_row_expense(monthlyDataSheet[rowIndex], taxYear, category,true)
            outgoingExpenses.each do |expenseData|
              #Rails.logger.debug("Outgoing Expense Data: #{expenseData}")
              expenses << expenseData
            end
          end
        end
      end
    end
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
              customerList += parse_customer_list(sheet.sheet_data)
            elsif sheetName.start_with?(PROPERTY_INCOME_SHEET_NAME_PREFIX)
              monthlyReportList << parse_monthly_report(sheet.sheet_data)
            end
          end
          successReport << File.basename(r)
        end
        Rails.logger.debug("Parsed customer list: #{customerList}")
        Rails.logger.debug("Parsed monthly report list: #{monthlyReportList}")
        Rails.logger.debug("Suceeded parsing list: #{successReport}")

        persist_customer_list_data(customerList) if !customerList.empty?
        persist_monthly_report_data(monthlyReportList) if !monthlyReportList.empty?

      rescue ReportParsingException => e
        Rails.logger.debug('ReportParsingException raised!')
        respondJson['parseSuccess'] = false
        respondJson['errorMsg'] = e.message

        render json: respondJson
      ensure
        if extractDirectory && extractDirectory.start_with?(fileDirectory)
          FileUtils.rm_rf(extractDirectory)
          Rails.logger.debug("Temp extracted directory removed at #{extractDirectory}")
        end
      end
      # if parsing process succeed
      report.update(parsed: true)
      respondJson['parseSuccess'] = true
    end
    render json: respondJson
  end
end