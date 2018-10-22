Rails.application.routes.draw do

  # Report route
  get 'report/index'
  #post 'report/send_email' => "report#send_email"
  get 'report/parse_report/:id' => "report#parse_report"
  get 'report/find_expenses' => "report#find_expenses"
  get 'report/send_report/:id' => 'report#send_report'

  # housing_report report route
  post 'housing_report/upload_report' => "housing_report#upload_report"
  get 'housing_report/delete_report' => "housing_report#delete_report"
  get 'housing_report/list_report' => "housing_report#list_report"

  # Authentication route
  get 'authentication' => "authentication#authenticate"

  # Detail list route
  get 'detail_list/list_user' => "detail_list#list_user"
  get 'detail_list/find' => "detail_list#find_property_and_tenant_by_user"

  # email setting route
  get 'email_setting/get_setting' => "email_setting#get_email_setting"
  post 'email_setting/update_setting' => "email_setting#update_email_setting"

  # email job route
  get 'email_job/start_job' => "email_job#start_email_job"
  get 'email_job/stop_job' => "email_job#stop_email_job"
  get 'email_job/create_job' => "email_job#create_email_job"
  get 'email_job/list_job' => "email_job#list_email_job"
  get 'email_job/update_job' => "email_job#update_email_job"

  #resque backend
  require 'resque/server'
  require 'resque-scheduler'
  require 'resque/scheduler/server'
  mount Resque::Server.new, at: '/resque'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end