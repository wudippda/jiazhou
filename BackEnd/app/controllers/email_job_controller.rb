class EmailJobController < ApplicationController

  def job_name_exists?
    return !EmailJob.find_by(job_name: params[:job_name]).nil?
  end

  def create_email_job
    success = false
    errors = Hash.new

    ActiveRecord::Base.transaction do
      report_start = DateTime.strptime(params[:report_start], ApplicationHelper::EXPENSE_DATE_FORMAT_STRING)
      report_end = DateTime.strptime(params[:report_end], ApplicationHelper::EXPENSE_DATE_FORMAT_STRING)
      emailJob = EmailJob.create!({job_name: params[:job_name], from: params[:from], to: params[:to], report_start: report_start.to_s,
                                  report_end: report_end.to_s, job_type: params[:job_type], config: params[:config]})
      emailJob.job_status_idle!
    end
    success = true
  rescue ActiveRecord::RecordInvalid, ArgumentError => e
    Rails.logger.error(e.record.errors)
    errors = e.record.errors
  ensure
    render json: errors.size > 0 ? {errors: errors}.merge!({success: success}) : {success: success}
  end

  def update_email_job
    success = false
    errors = Hash.new
    updates = Hash.new

    begin
      emailJob = EmailJob.find_by!(id: params[:id])
      EmailJob.column_names.each do |attr|
        # skip 'id' column
        next if attr == 'id'
        if params[attr]
          updates[attr] = params[attr]
        else
          updates.delete(attr)
        end
      end
      emailJob.update!(updates)
      success = true
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, ArgumentError => e
      Rails.logger.error(e.message)
      errors = e.message
    end
    render json: errors.size > 0 ? {errors: errors}.merge!({success: success}) : {success: success}
  end

  def list_email_job
    results =  EmailJob.all.order('created_at DESC').page(params[:page])
    render json: {reports: results.as_json, totalPage: results.total_pages, currentPage: params[:page]}
  end

  def start_email_job
    success = false
    errors = Hash.new
    config = Hash.new

    begin
      emailJob = EmailJob.find_by!(id: params[:id])
      scheduleConfig = JSON.parse(emailJob.config).symbolize_keys

      case emailJob.job_type.downcase
        when EmailJob.job_types[:schedule]
          if scheduleConfig[:cron].nil? && scheduleConfig[:every].nil?
            errors = {config: 'either "cron" nor "every" config should be present for a schedule job!'}
          elsif !emailJob.job_status_idle?
            errors = {status: 'only idle job can be started!'}
          else
            if scheduleConfig[:cron].nil?
              config[:every] = [scheduleConfig[:every], { first_in: scheduleConfig[:first_in] ? scheduleConfig[:first_in] : '1s'}]
            else
              config[:cron] = scheduleConfig[:cron]
            end
            config[:class] = SendEmailJob.name
            config[:persist] = true
            config[:args] = {jobId: emailJob.id, from: emailJob.from, to: emailJob.to,
                             report_start: emailJob.report_start, report_end: emailJob.report_end}.values
            res = Resque.set_schedule(emailJob.job_name, config)
            if res
              emailJob.job_status_scheduled!
              success = true
            end
          end
        when EmailJob.job_types[:now]
          # run as one-shot resque job
          if emailJob.job_status_idle?
            Resque.enqueue(SendEmailJob, jobId, User.find_by(email: emailJob.email), emailJob.to,
                         emailJob.report_start, emailJob.report_end)
            success = true
          end
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error(e.record.errors)
      errors = e.record.errors
    end
    render json: errors.size > 0 ? {errors: errors}.merge!({success: success}) : {success: success}
  end

  def stop_email_job
    success = false
    errors = Hash.new

    emailJob = EmailJob.find_by!(id: params[:id])
    if !emailJob.job_status_scheduled?
      errors = {job_status: 'Only scheduled job can be stopped!'}
    else
      Resque.remove_schedule(emailJob.job_name)
      emailJob.job_status_idle!
      success = true
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error(e.message)
    errors = e.message
  ensure
    render json: errors.size > 0 ? {errors: errors}.merge!({success: success}) : {success: success}
  end

  def delete_email_job
    success = false
    errors = Hash.new

    emailJob = EmailJob.find_by!(id: params[:id])
    if !emailJob.job_status_idle?
      errors = {job_status: 'A job can be deleted only when it is idle!'}
    else
      emailJob.destroy!
      success = true
    end
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotDestroyed => e
    Rails.logger.error(e.message)
    errors = e.message
  ensure
    render json: errors.size > 0 ? {errors: errors}.merge!({success: success}) : {success: success}
  end

end
