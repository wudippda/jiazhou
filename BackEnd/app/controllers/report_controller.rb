require 'csv'
require 'rubyXL'

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
  EXPENSE_OUTGOING_START_ANCHOR = 'Expenses'
  EXPENSE_OUTGOING_STOP_ANCHOR = 'Total Expenses'

  # public apis
  def index
    #UserMailer.with(receiver: User.new(id: 1, first_name:"Francis", last_name:"Zhong", email: "francis.zhong@sap.com")).incoming_email.deliver_now
  end

  def encode(str)
    return ApplicationHelper.forceToDefaultEncoding(str)
  end

  def readValue(value)
    return encode(value.to_s || EMPTY_VALUE).strip
  end

  def send_report
    @user = User.find(params[:user_id])
    @reportType = params[:report_type]

    if @user
      @report = generate_report(@user, @report_type)
      UserMailer.with(receiver: @user, report: @report).incoming_email.deliver_now
    end

    respond_to do |format|
      format.html { render 'index.html.erb'}
    end
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
          nonEmpty = true if value
        end
        if nonEmpty
          Rails.logger.info("Row data: #{rowData.to_s}")
          parse_customer_list_by_row(rowData)
        end
        tableRowIdx += 1
      end
    end
  end

  def parse_customer_list_by_row(rowData)
    ownerEmail = rowData[PROPERTY_OWNER_EMAIL_LABEL]
    # Find user by email, if not existed, create corresponding user in DB
    @user = User.where(email: ownerEmail).first_or_create do |user|
      Rails.logger.info("User not existed, creating...")
      user.name = rowData[PROPERTY_OWNER_NAME_LABEL]
      user.phone_number = rowData[PROPERTY_OWNER_PHONE_LABEL]
    end
    # find the property by both address and lot attributes, or create one if not existed.
    propertyAddress = rowData[PROPERTY_ADDRESS_LABEL]
    propertyLot = rowData[PROPERTY_LOT_LABEL]
    @property = @user.properties.where(address: propertyAddress, lot: propertyLot).first_or_create do |property|
      property.address = propertyAddress
      property.lot = propertyLot
    end

    # remove spaces from tenant email value
    tenantEmail = encode(rowData[TENANT_EMAIL_LABEL].gsub(/\s+/, "").strip)
    @tenant = @user.tenants.where(tenant_email: tenantEmail).first_or_create do |tenant|
      # If tenant not existed, create it
      tenant.tenant_phone = rowData[TENANT_PHONE_LABEL]
      tenant.tenant_name = rowData[TENANT_NAME_LABEL]
    end

    # update expire date
    expireDate = rowData[EXPIRE_DATE_LABEL]
    @rentingContract = @user.renting_contracts.where(tenant_id: @tenant.id).update(expire_date: DateTime.strptime(expireDate))
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
        type: readValue(row[0])
      }
      return resArray
  end

  def parse_monthly_report(monthlyDataSheet)
    if monthlyDataSheet
      propertyOwner = readValue(monthlyDataSheet[3][0].value)
      taxYear = readValue(monthlyDataSheet[3][7].value)
      propertyAddress = readValue(monthlyDataSheet[3][9].value).gsub(/^[0-9]*\)\s+/,"")

      @property = nil
      Property.where(address: propertyAddress).each do |property|
        @property = property if property.user.name == propertyOwner
      end

      # Read incoming
      incomingExpenses = parse_single_row_expense(monthlyDataSheet[15], taxYear, false)
      incomingExpenses.each do |expenseData|
        @property.expenses.where(date: expenseData.date).first_or_create do |expense|
          expense.date = expenseData.date
          expense.is_cost = expenseData.is_cost
          expense.cost = expenseData.cost
          expense.type = expenseData.type
        end
      end

      expenseRowIndex = 0
      while monthlyDataSheet[expenseRowIndex] && monthlyDataSheet[expenseRowIndex][0] != EXPENSE_OUTGOING_START_ANCHOR
        expenseRowIndex += 1
      end
      expenseRowIndex += 1

      # Read outgoing cost
      while monthlyDataSheet[expenseRowIndex] && monthlyDataSheet[expenseRowIndex][0] != EXPENSE_OUTGOING_STOP_ANCHOR
        parse_single_row_expense(monthlyDataSheet[expenseRowIndex], taxYear, true).each do |expenseData|
          @property.expenses.where(date: expenseData.date).first_or_create do |expense|
            expense.date = expenseData.date
            expense.is_cost = expenseData.is_cost
            expense.cost = expenseData.cost
            expense.type = expenseData.type
          end
        end
      end
    end
  end

  def parse_report()
    uploadSuccess = false
    parseSuccess = false

    workbook = RubyXL::Parser.parse("/Users/i320107/Desktop/report_sample.xlsx")
    # Read customer worksheet
    customerSheetData = workbook.worksheets[0].sheet_data
    monthlySheetData = workbook.worksheets[1].sheet_data

    parse_customer_list(customerSheetData)
    parse_monthly_report(monthlySheetData)

    render json: {uploadRes: uploadSuccess, parseRes: parseSuccess}
  end

  # private methods
  private
    def generate_report(user, report_type)
      #Implement report generation...
    end

end
