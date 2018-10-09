class ReportController < ApplicationController

  PROPERTY_OWNER_NAME_LABEL = 'PROPERTY OWNER'
  PROPERTY_OWNER_EMAIL_LABEL = 'OWNER EMAIL'
  PROPERTY_OWNER_PHONE_LABEL = 'OWNER PHONE#'
  PROPERTY_ADDRESS_LABEL = 'PROPERTY ADDRESS'
  PROPERTY_LOT_LABEL = 'LOT'
  TENANT_EMAIL_LABEL = 'TENANT EMAIL'
  TENANT_NAME_LABEL = 'TENANT(S)'
  TENANT_PHONE_LABEL = 'TENANT PHONE#'
  EXPIRE_DATE_LABEL = 'LEASE EXPIRE DATE'
  EXPENSE_DATE_FORMAT_STRING = '%m/%Y'
  EMPTY_VALUE = ''
  MONTH_COUNT_FOR_ONE_YEAR = 12
  EXPENSE_COST_FORMAT_STRING = '%.2f'
  MONTH_INCOME_TAX_YEAR_ANCHOR = 'Tax Year:'.downcase
  MONTH_INCOME_ANCHOR = 'Income'.downcase
  MONTH_INCOME_PROPERTY_OWNER_ANCHOR = 'Rental Property Income Expense Statement For:'.downcase
  MONYH_INCOME_PROPERTY_ADDRESS_ANCHOR = 'Property Address:'.downcase
  EXPENSE_OUTGOING_START_ANCHOR = 'Expenses'.downcase
  EXPENSE_OUTGOING_STOP_ANCHOR = 'Total Expenses'.downcase

  # public apis
  def find_expenses
    res = nil
    User.find_by(id: 1).properties.each do |property|
      res = property.findExpensesBetween(DateTime.strptime('2/2017', EXPENSE_DATE_FORMAT_STRING), DateTime.strptime('5/2017', EXPENSE_DATE_FORMAT_STRING))
      break
    end
    render json: {res: res}
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

  def parse_customer_list(customerSheetData)
    if customerSheetData && customerSheetData[0]
      tableColSize = customerSheetData[0].cells.size
      # Read table headers
      tableHeaders = Array.new
      customerSheetData[0].cells.each do |header|
        value = header && header.value.strip.try(:upcase)
        tableHeaders << value
      end
      Rails.logger.debug("Table headers: #{tableHeaders}")

      # Row index, start from 1 to skip title row
      tableRowIdx = 1
      while customerSheetData[tableRowIdx]
        rowData = Hash.new
        nonEmpty = false
        tableColSize.times do |idx|
          value = customerSheetData[tableRowIdx][idx].value
          rowData[tableHeaders[idx]] = readValue(value || EMPTY_VALUE)
          nonEmpty = true if nonEmpty || value
        end
        if nonEmpty
          Rails.logger.debug("Row data: #{rowData.to_s}")
          parse_customer_list_by_row(rowData)
        end
        tableRowIdx += 1
      end
    end
  end

  def parse_customer_list_by_row(rowData)
    ownerEmail = rowData[PROPERTY_OWNER_EMAIL_LABEL]
    # Find user by email, if not existed, create corresponding user in DB
    @user = User.where(email: ownerEmail).first_or_create! do |user|
      Rails.logger.debug("User not existed, creating...")
      user.name = rowData[PROPERTY_OWNER_NAME_LABEL]
      user.phone_number = rowData[PROPERTY_OWNER_PHONE_LABEL]
    end
    # remove spaces from tenant email value
    tenantEmail = encode(rowData[TENANT_EMAIL_LABEL].gsub(/\s+/, "").strip)
    @tenant = @user.tenants.where(tenant_email: tenantEmail).first_or_create! do |tenant|
      # If tenant not existed, create it
      tenant.tenant_phone = rowData[TENANT_PHONE_LABEL]
      tenant.tenant_name = rowData[TENANT_NAME_LABEL]
    end
    # find the property by both address and lot attributes, or create one if not existed.
    propertyAddress = rowData[PROPERTY_ADDRESS_LABEL]
    propertyLot = rowData[PROPERTY_LOT_LABEL]
    @property = @user.properties.where(address: propertyAddress, lot: propertyLot).first_or_create! do |property|
      Rails.logger.debug("Property not existed, creating...")
      property.address = propertyAddress
      property.lot = propertyLot
    end

    expireDate = rowData[EXPIRE_DATE_LABEL]
    @rentingContract = @user.renting_contracts.where(tenant_id: @tenant.id).update(property_id: @property.id,
                                                                                   expire_date: DateTime.strptime(expireDate))
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

  def parse_single_row_expense(row, taxYear, isCost)
    resArray = Array.new
    MONTH_COUNT_FOR_ONE_YEAR.times do |idx|
      date = DateTime.strptime("#{idx + 1}/#{taxYear}", EXPENSE_DATE_FORMAT_STRING)
      resArray << {
          date: date,
          is_cost: isCost,
          cost: costToDecimal(readValue(row[idx + 2].value)),
          category: readValue(row[0].value)
      }
    end
    return resArray
  end

  def parse_monthly_report(monthlyDataSheet)
    if monthlyDataSheet

      #propertyOwner = readValue(monthlyDataSheet[3][0].value)
      #taxYear = readValue(monthlyDataSheet[7][0].value).gsub(/\D/, EMPTY_VALUE)
      #propertyAddress = readValue(monthlyDataSheet[9][0].value).gsub(/^[0-9]*\)\s+/,EMPTY_VALUE)

      taxYearIndex = findIndexByAnchor(monthlyDataSheet, MONTH_INCOME_TAX_YEAR_ANCHOR, -1, 0)
      taxYear = readValue(monthlyDataSheet[taxYearIndex[0]][0].value).gsub(/\D/, EMPTY_VALUE) if taxYearIndex[0] != -1

      propertyOwnerIndex = findIndexByAnchor(monthlyDataSheet, MONTH_INCOME_PROPERTY_OWNER_ANCHOR, -1, 0)
      propertyOwner = EMPTY_VALUE
      if propertyOwnerIndex[0] != -1 && monthlyDataSheet[propertyOwnerIndex[0] + 1] && monthlyDataSheet[propertyOwnerIndex[0] + 1][0]
        propertyOwner = readValue(monthlyDataSheet[propertyOwnerIndex[0] + 1][0].value)
      end

      propertyAddressIndex = findIndexByAnchor(monthlyDataSheet, MONYH_INCOME_PROPERTY_ADDRESS_ANCHOR, -1, 0)
      propertyAddress = EMPTY_VALUE
      if propertyAddressIndex[0] != -1 && monthlyDataSheet[propertyAddressIndex[0] + 1] && monthlyDataSheet[propertyAddressIndex[0] + 1][0]
        propertyAddress = readValue(monthlyDataSheet[propertyAddressIndex[0] + 1][0].value).gsub(/^[0-9]*\)\s+/,EMPTY_VALUE)
      end

      Rails.logger.debug("Tax Year pos: #{taxYearIndex}, Owner pos: #{propertyOwnerIndex}, Address pos: #{propertyAddressIndex}")
      Rails.logger.debug("Tax Year: #{taxYear}, Owner: #{propertyOwner}, Address: #{propertyAddress}")

      propertyForIncome = nil
      Property.where(address: propertyAddress).each do |property|
        if property.user.name.downcase == propertyOwner.downcase
          propertyForIncome = property
          break
        end
      end

      if !propertyForIncome.nil?

        # Read incoming expenses
        incomingExpensesAnchor = findIndexByAnchor(monthlyDataSheet, MONTH_INCOME_ANCHOR, -1, 0)
        if incomingExpensesAnchor[0] != -1
          incomingExpenses = parse_single_row_expense(monthlyDataSheet[incomingExpensesAnchor[0]], taxYear, false)
          incomingExpenses.each do |expenseData|
            Rails.logger.debug("Expense Data: #{expenseData}")
            expenseData['property_id'] = propertyForIncome.id
            Expense.new(expenseData).save!
          end
        end

        # Read outgoing expenses
        expenseStartIndex = findIndexByAnchor(monthlyDataSheet, EXPENSE_OUTGOING_START_ANCHOR, -1, 0)
        expenseStopIndex = findIndexByAnchor(monthlyDataSheet, EXPENSE_OUTGOING_STOP_ANCHOR, -1, 0)

        Rails.logger.debug("Expense start pos: #{expenseStartIndex}, Expense stop pos: #{expenseStopIndex}")

        if expenseStartIndex[0] != -1 && expenseStopIndex[0] != -1
          (expenseStartIndex[0] + 1..expenseStopIndex[0] - 1).each do |rowIndex|
            outgoingExpenses = parse_single_row_expense(monthlyDataSheet[rowIndex], taxYear, true)
            outgoingExpenses.each do |expenseData|
              expenseData['property_id'] = propertyForIncome.id
              Expense.new(expenseData).save!
            end
          end
        end
      end
    end
  end

  def parse_report
    parseSuccess = false
    excelReport = ExcelReport.find_by(id: params[:id])

    if excelReport && !excelReport.parsed && excelReport.excel.file
      workbook = RubyXL::Parser.parse(excelReport.excel.current_path)
      # Read customer worksheet
      customerSheetData = workbook.worksheets[0].sheet_data
      monthlySheetData = workbook.worksheets[1].sheet_data

      parse_customer_list(customerSheetData)
      parse_monthly_report(monthlySheetData)

      # if parsing process succeed
      excelReport.update_attributes(parsed: true)
      parseSuccess = true
    end

    render json: {parseRes: parseSuccess}
  end

  # private methods
  private
    def generate_report(user, report_type)
      #Implement report generation...
    end

end