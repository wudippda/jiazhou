class UserMailer < ApplicationMailer

  DEFAULT_SUBJECT = "Monthly Incoming & Expense Report for"
  INCOME_LABEL = 'Income'.downcase
  NOT_AVAILABLE = 'N/A'
  IMAGE_CHART_BASE_URL = 'https://image-charts.com/chart?'
  IMAGE_SIZE = '250x250'

  # Mail configuration
  after_action :set_email_configuration
  helper_method :costValueToStr

  def incoming_email(from, to, date)
    dt = DateTime.strptime(date, ApplicationHelper::EXPENSE_DATE_FORMAT_STRING)
    @receiver = from
    @month = dt.month
    @year = dt.year
    temp = Hash.new
    @expenses = Hash.new

    @propertyIds = @receiver.properties.all.map(&:id).sort
    @receiver.properties.each {|property| temp.merge!(property.findExpensesBetween(date, date, :category)){|key, oldval, newval| newval + oldval}}
    temp.each { |key, value| @expenses[key] = value.group_by{ |e| e.property_id } }

    @totalIncomes = 0
    @outgoingSubtotal = Hash[@propertyIds.map {|x| [x, 0]}]

    @expensePieChartUrl = generateExpenseChart(temp)
    @propertyIncomePieChartUrl = generatePropertyIncomeChart(temp)

    mail(from: from, to: to, subject: generate_subject)
  end

  def costValueToStr(value)
    # Ensure to operate on string
    value = value.to_s
    size = value.size
    if size > 3
      count = (size / 3) - (size % 3 == 0 ? 1 : 0)
      count.times { |t| value = value.insert(-4 * (t + 1), ',') }
    end
    return "$#{value}.00"
  end

  def generatePropertyIncomeChart(expenses)
    chdl = Array.new
    chl = Array.new
    chd = Array.new
    Rails.logger.info(expenses)
    expenses.each do |key, value|
      if key.downcase == INCOME_LABEL
        chdl = value.collect { |nv| "Property #{nv.property_id}" }.join('|')
        chl = value.collect { |nv| nv.cost }
        totalIncome = chl.inject(0, :+)
        chd = chl.collect { |nv| nv.to_f / totalIncome}.join(',')
        chl = chl.collect { |nv| costValueToStr(nv) }.join('|')
        break
      end
    end
    return "#{IMAGE_CHART_BASE_URL}chs=#{IMAGE_SIZE}&chd=t:#{chd}&cht=pd&chl=#{chl}&chdl=#{chdl}"
  end

  def generateExpenseChart(expenses)
    chdl = Array.new
    chd = Array.new
    total = Hash.new
    totalSum = 0
    expenses.each do |key, value|
      sum = 0
      value.each { |e| sum += e.cost}
      if key.downcase != INCOME_LABEL && sum > 0
        chdl << key
        total[key] = sum
        totalSum += sum
      end
    end
    chdl.each do |category|
      chd << (total[category].to_f / totalSum)
    end
    chd = chd.join(',')
    chdl = chdl.join('|').gsub('&', 'and')
    chl = total.values.collect!{ |v| "#{costValueToStr(v)}" }.join('|')

    return "#{IMAGE_CHART_BASE_URL}chs=#{IMAGE_SIZE}&chd=t:#{chd}&cht=pd&chl=#{chl}&chdl=#{chdl}"
  end

  def generate_subject
    return "[AUTOMATIC] #{DEFAULT_SUBJECT} #{@receiver.name.capitalize}"
  end

  def set_email_configuration
    @email_settings = EmailSettingHelper.get_email_setting(Rails.env)
    Rails.logger.debug(@email_settings.symbolize_keys)
    mail.delivery_method.settings.merge!(@email_settings.symbolize_keys)
    Rails.logger.debug(mail.delivery_method.settings)
  end
end
