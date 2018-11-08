class MonthlyReportMailer < ApplicationMailer

  DEFAULT_SUBJECT = "Monthly Incoming & Expense Report for"
  INCOME_LABEL = 'Income'.downcase
  NOT_AVAILABLE = 'N/A'
  IMAGE_CHART_BASE_URL = 'https://image-charts.com/chart?'
  IMAGE_SIZE = '250x250'

  class ExpenseMissingException < StandardError
  end

  # Mail configuration
  after_action :set_email_configuration
  helper_method :costValueToStr

  def send_out(from, to, taskParams)
    monthly_report_email(from, to, taskParams)
  end

  def monthly_report_email(from, to, taskParams)
    date = DateTime.strptime("#{taskParams[:month]}/#{taskParams[:year]}", ApplicationHelper::EXPENSE_DATE_FORMAT_STRING)
    dt = date
    Rails.logger.debug("Date parsed: #{dt}")
    @receiver = User.find_by!(email: to)

    @month = dt.month
    @year = dt.year
    Rails.logger.debug("Year: #{@year}, Month: #{@month}")
    Resque.logger.debug("In Email Job! Year: #{@year}, Month: #{@month}")

    temp = Hash.new
    @expenses = Hash.new

    @propertyIds = @receiver.properties.all.map(&:id).sort
    @receiver.properties.each {|property| temp.merge!(property.findExpensesBetween(dt, dt, :category)){|key, oldval, newval| newval + oldval}}
    temp.each { |key, value| @expenses[key] = value.group_by{ |e| e.property_id } }

    Rails.logger.debug(@expenses)
    raise ExpenseMissingException.new("Can not find any expense for user #{to} within #{dt}") if @expenses.empty?

    @totalIncomes = 0
    @outgoingSubtotal = Hash[@propertyIds.map {|x| [x, 0]}]

    @expensePieChartUrl = generateExpenseChart(temp)
    @propertyIncomePieChartUrl = generatePropertyIncomeChart(temp)

    mail(from: from, to: to, subject: generate_subject, template_name: 'monthly_report_email')
  rescue StandardError => e
    raise e
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
    expenses.each do |key, value|
      if key.downcase == INCOME_LABEL
        chdl = value.collect { |nv| "Property #{nv.property_id}" }.join('|')
        chl = value.collect { |nv| nv.cost }
        totalIncome = chl.inject(0, :+)
        chd = chl.collect { |nv| nv.to_f / totalIncome }.join(',')
        chl = chl.collect { |nv| costValueToStr(nv) }.join('|')
        break
      end
    end
    return chd.include?('NaN') ? "" : "#{IMAGE_CHART_BASE_URL}chs=#{IMAGE_SIZE}&chd=t:#{chd}&cht=pd&chl=#{chl}&chdl=#{chdl}"
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

    return (chd.empty? || chdl.empty? || chl.empty?) ? "" : "#{IMAGE_CHART_BASE_URL}chs=#{IMAGE_SIZE}&chd=t:#{chd}&cht=pd&chl=#{chl}&chdl=#{chdl}"
  end

  def generate_subject
    return "[AUTOMATIC] #{DEFAULT_SUBJECT} #{@receiver.name.capitalize}"
  end

  def set_email_configuration
    @email_settings = EmailSettingHelper.get_email_setting(Rails.env)
    Resque.logger.info(@email_settings.symbolize_keys)
    mail.delivery_method.settings.merge!(@email_settings.symbolize_keys)
    Resque.logger.info("Email settings after merge: #{mail.delivery_method.settings}")
  end
end
