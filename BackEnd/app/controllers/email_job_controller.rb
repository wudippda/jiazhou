class EmailJobController < ApplicationController
  include EmailJobDoc

  EMAIL_JOB_ALLOWED_TO_UPDATE = %w(from to config)
  EMAIL_TASK_ALLOWED_TO_UPDATE = %w(task_type_id task_params)

  def create_email_job
    success = false
    errors = Hash.new

    ActiveRecord::Base.transaction do
      emailJob = EmailJob.create!({job_name: params[:job_name], from: params[:from], to: params[:to], job_type: params[:job_type], config: params[:config]})
      emailJob.create_email_task!({task_type_id: params[:task_type_id], task_params: params[:task_params]})
    end
    success = true
  rescue ActiveRecord::RecordInvalid, ArgumentError => e
    Rails.logger.error(e.message)
    errors = e.message
  ensure
    render json: errors.size > 0 ? {errors: errors}.merge!({success: success}) : {success: success}
  end

  def update_email_job
    success = false
    errors = Hash.new
    updates = Hash.new
    taskUpdates = Hash.new

    begin
      ActiveRecord::Base.transaction do
        emailJob = EmailJob.find_by!(id: params[:id])
        EMAIL_JOB_ALLOWED_TO_UPDATE.each { |attr| updates[attr] = params[attr] if params[attr] }
        emailJob.update!(updates) if !updates.empty?

        EMAIL_TASK_ALLOWED_TO_UPDATE.each { |taskAttr| taskUpdates[taskAttr] = params[taskAttr] if params[taskAttr]}
        emailJob.email_task.update!(taskUpdates) if !taskUpdates.empty?
      end

      success = true
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, ArgumentError => e
      Rails.logger.error(e.message)
      errors = e.message
    end
    render json: errors.size > 0 ? {errors: errors}.merge!({success: success}) : {success: success}
  end

  def get_task_id_mapping
    mapping = Array.new
    EmailTaskHelper.getTaskTypes.each { |task| mapping << {id: task['id'], taskName: task['taskName']} }
    render json: mapping
  end

  def list_email_job
    results =  EmailJob.all.order('created_at DESC').page(params[:page]) || Array.new
    render json: { jobs: results.as_json }.merge!(results.empty? ? {} : { totalPage: results.total_pages, currentPage: params[:page] })
  end

  def list_email_job_history
    success = false
    errors = Hash.new
    results = Array.new

    begin
      emailJob = EmailJob.find_by(id: params[:id])
      results = emailJob.email_job_histories.all.order('created_at DESC').page(params[:page])
    rescue ActiveRecord::RecordNotFound, StandardError => e
      Rails.logger.error(e.message)
      errors = e.message
    end
    render json: { histories: results.as_json }.merge!(results.empty? ? {} : { totalPage: results.total_pages, currentPage: params[:page] })
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
          if scheduleConfig[:cron].nil?
            errors = {config: '"cron" config should be present for a schedule job!'}
          elsif !emailJob.job_status_idle?
            errors = {status: 'only idle job can be started!'}
          else
            repeatParams = Hash.new
            repeatParams[:first_in] = scheduleConfig[:first_in] || '1s'

            # last_at takes more priority than times
            if scheduleConfig[:last_in]
              repeatParams[:last_in] = scheduleConfig[:last_in]
            else
              repeatParams[:times] = scheduleConfig[:times].to_i if scheduleConfig[:times]
            end

            if !scheduleConfig[:time_zone].nil?
              tz = ActiveSupport::TimeZone::MAPPING[scheduleConfig[:time_zone]]
              scheduleConfig[:cron] = "#{scheduleConfig[:cron]} #{tz}" if !tz.nil?
            end

            config[:cron] = scheduleConfig[:cron]
            config[:class] = SendEmailJob.name
            config[:persist] = true
            config[:args] = [emailJob.id, emailJob.from, emailJob.to]
            res = Resque.set_schedule(emailJob.job_name, config)
            if res
              emailJob.job_status_scheduled!
              Rails.logger.debug("config[:cron] value: #{config[:cron]}")
              timeFormat = ApplicationHelper::EOTIME_DATE_FORMAT_STRING
              nextTime = DateTime.strptime(Rufus::Scheduler.parse(config[:cron]).next_time.to_s, timeFormat)
              nextTime = nextTime.in_time_zone(ActiveSupport::TimeZone::MAPPING[scheduleConfig[:time_zone]]) if scheduleConfig[:time_zone]
              Rails.logger.debug("Next execution time: #{nextTime}")
              emailJob.update(next_time: nextTime)
              success = true
            end
          end
        when EmailJob.job_types[:now]
          # run as one-shot resque job
          if emailJob.job_status_idle?
            Resque.enqueue(SendEmailJob, emailJob.id, emailJob.from, emailJob.to)
            emailJob.update(next_time: DateTime.now)
            success = true
          end
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error(e.record.errors)
      errors = e.record.errors
    rescue StandardError => e
      Rails.logger.error(e.message)
      errors = e.message
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
