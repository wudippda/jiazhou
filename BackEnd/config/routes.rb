Rails.application.routes.draw do

  get 'report/index'
  post 'report/send_email' => "report#send_email"
  get 'report/parse_report' => "report#parse_report"
  get 'report/find_expenses' => "report#find_expenses"

  get 'email_setting/get_setting' => "email_setting#get_email_setting"
  post 'email_setting/update_setting' => "email_setting#update_email_setting"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end