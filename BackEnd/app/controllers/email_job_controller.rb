class EmailJobController < ApplicationController

  def job_name_exists?
    return !EmailJob.find_by(job_name: params[:job_name]).nil?
  end

  def create_email_job
    success = false
    errors = Array.new
    # Support 'now' and 'schedule' types in 1st version
    # config {jobName: <name>, type: <'schedule' | 'now' | 'delayed'>, every: <30s | 60m | 30d>, first_in: <5s | 10s>, cron: <59 23 31 12 5 *>}
    emailJob = EmailJob.create!({job_name: params[:job_name], from: params[:from], to: params[:to], report_start: params[:report_start],
                                 report_end: params[:report_end], job_type: params[:job_type], config: params[:config], status: EmailJob.statuses[:idle]})
    success = true
  rescue ActiveRecord::RecordInvalid => e
    errors << e.message
  ensure
    render json:{success: success}.merge!(errors.size > 0 ? {errors: errors} : {})
  end

  def list_email_job

  end

  def start_email_job
    success = false
    jobId = params[:id]
    emailJob = EmailJob.find_by(id: jobId)
    if !emailJob.nil?
      config = JSON.parse(emailJob.config)
      case emailJob.job_type.downcase
        when EmailJob.schedule?
          if emailJob.idle?
            config[:class] = SendEmailJob.name
            config[:persist] = true
            config[:args] = {jobId: jobId, from: User.find_by(email: emailJob.email), to: emailJob.to,
                             report_start: emailJob.report_start, report_end: emailJob.report_end}
            res = Resque.set_schedule(emailJob.job_name, config)
            if res
              success = true
              emailJob.update(status: EmailJob::statues.scheduled)
            end
          end
      when EmailJob.now?
        # run as one-shot resque job
        if emailJob.idle?
          Resque.enqueue(SendEmailJob, jobId, User.find_by(email: emailJob.email), emailJob.to,
                       emailJob.report_start, emailJob.report_end)
        end
      end
    end

    render json: {success: success}
  end

  def stop_email_job
    success = false
    jobId = params[:id]
    emailJob = EmailJob.find_by(id: jobId)
    if !emailJob.nil?
      Resque.remove_schedule(emailJob.name)
      success = true
    else
      # email job not found!
    end
    render json: {success: success}
  end
end
