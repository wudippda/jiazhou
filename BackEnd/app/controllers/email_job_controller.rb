class EmailJobController < ApplicationController

  def job_name_exists?
    return !EmailJob.find_by(job_name: params[:job_name]).nil?
  end

  def create_email_job
    success = false
    errors = Array.new
    jobName = params[:job_name]
    if job_name_exists?
      errors << "job name #{jobName} already exists!"
      render json:{success: success, errors: errors}
    end
    isScheduleJob = params[:isSchedule]


    config = {name: jobName}
    render json:{success: true}
  end

  def start_email_job
    name = 'send_emails'
    config = {}
    config[:class] = 'SendEmailJob'
    config[:args] = 'POC email subject'
    config[:every] = ['5s', {first_in: '5s'}]
    config[:persist] = true
    job = Resque.set_schedule(name, config)
    Rails.logger.info(job)
    render json: {success: true}
  end

  def stop_email_job
    name = 'send_emails'
    Resque.remove_schedule(name)
    render json: {success: true}
  end

end
