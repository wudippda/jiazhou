class SendEmailJob
  @queue = :send_emails

  SEMICOLON = ';'

  def self.before_perform_scan_update_status(jobId)
    @emailJob = EmailJob.find_by(id: jobId)
    if !emailJob.nil?
      emailJob.active!
    else
      #Resque.logger.error("Job with related id not found! Quit job.")
      raise Resque::Job::DontPerform, 'Job with related id not found! Quit job.'
    end
  end

  def self.perform(jobId, from, to, report_start, report_end)
    executionHistory = @emailJob.email_job_histories.create({execution_time: Time.now})
    sendRes = {success_to: 0, fail_to: 0, total_to: tos.size,
               success_to_list: Array.new, fail_to_list: Array.new}

    # currently only supports monthly report
    if report_start != report_end
      Resque.logger.error("Only monthly report is supported!")
    else
      tos = to.split(SEMICOLON)
      tos.each do |t|
        begin
          UserMailer.incoming_email(from, to, report_end).deliver_now
          sendRes[:success_to] += 1
          sendRes[:success_to_list] << t
        rescue StandardError => e
          Resque.logger.error("Error occurs when sending email to #{t}.")
          sendRes[:fail_to] += 1
          sendRes[:fail_to_list] << t
        end
      end
    end
  ensure
    execitionStatus = (sendRes[:fail_to] == 0 && sendRes[:success_to] == sendRes[:total_to]) ?
                          EmailJobHistory::statuses[:success] : EmailJobHistory::statuses[:fail]
    executionHistory.update(sendRes.merge!({status: execitionStatus}))
  end
end