module EmailJobDoc
  extend Apipie::DSL::Concern

  responseExample = {success: false, errors: "<errors>"}.to_s

  api :POST, '/email_job/create_job', 'Create a new email job'
  formats ['json']
  param :job_name, String, :desc => 'Name for the job', :required => true
  param :from, String, :desc => 'Email address that the be sent from', :required => true
  param :to, String, :desc => 'A semicolon-separated list of email addresses for candidates who should recieve this email (e.g. abc@abc.com;123@123.com)', :required => true
  param :job_type, [:now, :delay, :schedule], :desc => 'Type of the job', :required => true
  param :config, Hash, :desc => 'The configuration for "schedule" job or "delay" job, NOT required for "now" job' do
    param :cron, String, :desc => "cron schedule for schedule job"
    param :time_zone, String, :desc => "The timezone used to run schedule job"
  end
  example responseExample
  def create_email_job ;end

  api :POST, '/email_job/update_job', 'Update the settings for existing email job'
  formats ['json']
  param :id, Integer, :desc => 'The job id for the email job to be updated', :required => true
  param :job_name, String, :desc => 'Name for the job'
  param :from, String, :desc => 'Email address that the be sent from'
  param :to, String, :desc => 'A semicolon-separated list of email addresses for candidates who should recieve this email (e.g. abc@abc.com;123@123.com)'
  param :job_type, [:now, :delay, :schedule], :desc => 'Type of the job'
  param :config, Hash, :desc => 'The configuration for schedule job or delay job, NOT required for now job' do
    param :cron, String, :desc => "cron schedule for schedule job"
    param :time_zone, String, :desc => "The timezone used to run schedule job"
  end
  example responseExample
  def update_email_job ;end

  api :GET, '/email_job/list_job', 'List all the email jobs'
  formats ['json']
  example "{jobs: <result_json>, totalPage: <totalPage>, currentPage: <currentPage>}"
  def list_email_job; end

  api :GET, '/email_job/list_job_history', 'List all the email job histories for a given job'
  formats ['json']
  example "{histories: <result_json>, totalPage: <totalPage>, currentPage: <currentPage>}"
  def list_email_job_history; end

  api :POST, '/email_job/start_job', 'Start a job. A job can be started only with "idle" status. For "schedule" job, the job
                                           is scheduled after calling "start_job"; Otherwise for a "now" job, it is executed immediatly after being started'
  param :id, Integer, :desc => 'The job id for the email job to be started', :required => true
  formats ['json']
  example responseExample
  def start_email_job; end

  api :POST, '/email_job/stop_job', 'Stop a job. Only a "schedule" job with "scheduled" status can be stopped'
  param :id, Integer, :desc => 'The job id for the email job to be stopped.', :required => true
  formats ['json']
  example responseExample
  def stop_email_job; end

  api :POST, '/email_job/delete_job', 'Delete a job. A job can be deleted only when its status is "idle"'
  param :id, Integer, :desc => 'The job id for the email job to be deleted.', :required => true
  formats ['json']
  example responseExample
  def delete_email_job; end

end