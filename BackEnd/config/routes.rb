Rails.application.routes.draw do

  # Report route
  get 'report/index'
  post 'report/send_email' => "report#send_email"
  get 'report/parse_report' => "report#parse_report"
  get 'report/find_expenses' => "report#find_expenses"

  # Excel report route
  post 'excel_report/upload_report' => "excel_report#upload_report"
  get 'excel_report/delete_report/:id' => "excel_report#delete_report"
  get 'excel_report/list_report' => "excel_report#list_report"

  get 'email_setting/get_setting' => "email_setting#get_email_setting"
  post 'email_setting/update_setting' => "email_setting#update_email_setting"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end