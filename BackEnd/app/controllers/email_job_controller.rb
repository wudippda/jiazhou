class EmailJobController < ApplicationController

  def job_name_exists?
    return !EmailJob.find_by(job_name: params[:job_name]).nil?
  end

  def create_email_job
    success = false
    errors = Hash.new
    emailJob = EmailJob.create!({job_name: params[:job_name], from: params[:from], to: params[:to], report_start: params[:report_start],
                                report_end: params[:report_end], job_type: params[:job_type], config: params[:config]})
    email.job_status_idle!
    success = true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
    errors = e.record.errors
  ensure
    render json:{success: success}.merge!(errors.size > 0 ? {errors: errors} : {})
  end

  def update_email_job
    success = false
    errors = Hash.new
    jobId = params[:id]
    emailJob = EmailJob.find_by(id: jobId)
    if !emailJob.nil?
      updates = Hash.new
      EmailJob.column_names.each do |attr|
        if params[attr]
          updates[attr] = params[attr]
        else
          updates.delete(attr)
        end
      end
      begin
        emailJob.update(updates)
        success = true
      rescue ActiveRecord::RecordInvalid, ArgumentError => e
        Rails.logger.error(e.message)
        errors = e.message
      end
    else
      errors = {id: "Email job with id #{jobId} not found!"}
    end
    render json:{success: success}.merge!(errors.size > 0 ? {errors: errors} : {})
  end

  def list_email_job

  end

  def start_email_job
    success = false
    errors = Hash.new
    jobId = params[:id]
    emailJob = EmailJob.find_by(id: jobId)
    if !emailJob.nil?
      config = Hash.new
      scheduleConfig = JSON.parse(emailJob.config).symbolize_keys
      case emailJob.job_type.downcase
      when EmailJob.job_types[:schedule]
        Rails.logger.info(emailJob.job_status_idle?)
        if scheduleConfig[:cron].nil? && scheduleConfig[:every].nil?
          errors = {config: 'either "cron" nor "every" config should be present for a schedule job!'}
        elsif emailJob.status != 0
          errors = {status: 'only idle job can be started!'}
        else
          if scheduleConfig[:cron].nil?
            Rails.logger.info(scheduleConfig)
            config[:every] = [scheduleConfig[:every], { first_in: scheduleConfig[:first_in] ? scheduleConfig[:first_in] : :now}]
          else
            config[:cron] = scheduleConfig[:cron]
          end
          config[:class] = SendEmailJob.name
          config[:persist] = true
          config[:args] = {jobId: jobId, from: emailJob.from, to: emailJob.to,
                           report_start: emailJob.report_start, report_end: emailJob.report_end}
          Rails.logger.info(config)
          res = Resque.set_schedule(emailJob.job_name, config)
          if res
            emailJob.scheduled!
            success = true
          end
        end
      when EmailJob.job_types[:now]
        # run as one-shot resque job
        if emailJob.idle?
          Resque.enqueue(SendEmailJob, jobId, User.find_by(email: emailJob.email), emailJob.to,
                       emailJob.report_start, emailJob.report_end)
          success = true
        end
      end
    end

    render json: {success: success}.merge!(errors.size > 0 ? {errors: errors} : {})
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
