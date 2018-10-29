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

    executionHistory = @emailJob.email_job_histories.create({execution_time: DateTime.now})
    sendRes = {success_to: 0, fail_to: 0, total_to: 0,
               success_to_list: Array.new, fail_to_list: Array.new}

    tos = to.split(EMAIL_SEPARATOR)
    sendRes[:total_to] = tos.size
    tos.each do |t|
      begin
        # Send monthly report based on the current month
        MonthlyReportMailer.send_monthly_report_email(from, to, DateTime.now).deliver_now
        sendRes[:success_to] += 1
        sendRes[:success_to_list] << t
      rescue StandardError => e
        Resque.logger.error(e)
        Resque.logger.error(e.backtrace)
        Resque.logger.error("Error occurs when sending email to #{t}.")
        sendRes[:fail_to] += 1
        sendRes[:fail_to_list] << t
        #sendRes[:error] = e.to_s
      end
    end
  ensure
    executionHistory.update(sendRes)
    if sendRes[:fail_to] == 0 && sendRes[:success_to] == sendRes[:total_to]
      executionHistory.job_history_status_success!
    else
      executionHistory.job_history_status_fail!
    end
    self.delete_lock_file(lockFilePath)
    Resque.logger.info("Recover old status: #{@oldStatus}")
    @emailJob.update(job_status: @oldStatus)
  end
end