class SendEmailJob
  @queue = :send_emails

  EMAIL_SEPARATOR = ';'
  JOB_LOCK_DIR = File.join(Rails.root, 'tmp', 'job_lock')
  Resque.logger.level = Logger::INFO

  def self.create_lock_file(file, jobId)
    FileUtils.mkdir_p(JOB_LOCK_DIR) if !Dir.exist?(JOB_LOCK_DIR)
    if File.exist? (file)
      message = "Lock file exists for job #{jobId} at #{Time.now}! A job is proccessing."
      Resque.logger.error(message)
      raise Resque::Job::DontPerform, message
    else
      Resque.logger.info("No existing lock file found for job #{jobId}. Creating...")
      File.write(file, '')
    end
  end

  def self.delete_lock_file(file)
    Resque.logger.info("Delete if file #{file} exists...")
    FileUtils.rm_f(file) if File.exist? (file)
  end

  def self.before_perform_update_scan_status(jobId, from, to)
    @emailJob = EmailJob.find_by(id: jobId)
    if !@emailJob.nil?
      @oldStatus = @emailJob.job_status
      @emailJob.job_status_active!
      Resque.logger.info("job #{jobId} is active!")
    else
      raise Resque::Job::DontPerform, 'Job with related id not found! Quit job.'
    end
  end

  def self.perform(jobId, from, to)
    Resque.logger.info("##### Email job started for job #{jobId} #####")
    lockFilePath = File.join(JOB_LOCK_DIR, ".job_lck_#{jobId.to_s}")
    self.create_lock_file(lockFilePath, jobId)

    executionHistory = @emailJob.email_job_histories.create!({execution_time: DateTime.now})
    sendRes = {success_to: 0, fail_to: 0, total_to: 0,
               success_to_list: Array.new, fail_to_list: Array.new, fail_errors: ''}

    tos = to.split(EMAIL_SEPARATOR)
    sendRes[:total_to] = tos.size
    now = DateTime.now
    date = DateTime.strptime("#{now.month}/#{now.year}", ApplicationHelper::EXPENSE_DATE_FORMAT_STRING)
    tos.each do |t|
      begin
        # Send monthly report for current month
        MonthlyReportMailer.monthly_report_email(from, to, date).deliver_now
        sendRes[:success_to] += 1
        sendRes[:success_to_list] << t
      rescue StandardError => e
        Resque.logger.error(e)
        Resque.logger.error(e.backtrace)
        Resque.logger.error("Error occurs when sending email to #{t}.")
        sendRes[:fail_to] += 1
        sendRes[:fail_to_list] << t
        sendRes[:fail_errors] += "#{e.to_s};"
      end
    end
    updateHistory(executionHistory, sendRes)
  ensure
    @emailJob.update(job_status: @oldStatus)
    delete_lock_file(lockFilePath)
    updateNextExecutionTime
  end

  def self.updateNextExecutionTime
    if @emailJob.job_type_schedule?
      config = JSON.parse(@emailJob.config).symbolize_keys
      if !@emailJob.config.nil? && config[:cron]
        timeFormat = ApplicationHelper::EOTIME_DATE_FORMAT_STRING
        nextTime = DateTime.strptime(Rufus::Scheduler.parse(config[:cron]).next_time.to_s, timeFormat)
        nextTime = nextTime.in_time_zone(ActiveSupport::TimeZone::MAPPING[scheduleConfig[:time_zone]]) if scheduleConfig[:time_zone]
        @emailJob.update(next_time: nextTime)
      else
        Rails.logger.error("No 'cron' config found for job #{@emailJob.id}")
      end
    elsif @emailjob.job_type_now?
      @emailJob.update(next_time: nil)
    end
  end

  def self.updateHistory(history, res)
    history.update(res)
    if res[:fail_to] == 0 && res[:success_to] == res[:total_to]
      history.job_history_status_success!
    else
      history.job_history_status_fail!
    end
  end
end