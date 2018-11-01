Rails.application.routes.draw do

  # The api doc route is only available in development env
  apipie if Rails.env.development?

  # Report route
  post 'report/parse_report' => "report#parse_report"

  # housing_report report route
  post 'housing_report/upload_report' => "housing_report#upload_report"
  post 'housing_report/delete_report' => "housing_report#delete_report"
  get 'housing_report/list_report' => "housing_report#list_report"

  # Authentication route
  post 'authentication' => "authentication#authenticate"

  # Detail list route
  get 'detail_list/list_user' => "detail_list#list_user"
  post 'detail_list/find' => "detail_list#find_property_and_tenant_by_user"

  # email setting route
  get 'email_setting/get_setting' => "email_setting#get_email_setting"
  post 'email_setting/update_setting' => "email_setting#update_email_setting"

  # email job route
  post 'email_job/start_job' => "email_job#start_email_job"
  post 'email_job/stop_job' => "email_job#stop_email_job"
  post 'email_job/create_job' => "email_job#create_email_job"
  get 'email_job/list_job' => "email_job#list_email_job"
  post 'email_job/update_job' => "email_job#update_email_job"
  post 'email_job/delete_job' => "email_job#delete_email_job"
  get 'email_job/list_job_history' => "email_job#list_email_job_history"

  #resque backend
  require 'resque/server'
  require 'resque-scheduler'
  require 'resque/scheduler/server'
  mount Resque::Server.new, at: '/resque'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end