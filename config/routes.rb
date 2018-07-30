Rails.application.routes.draw do

  resources :report

  get 'report/index'
  post 'report/send_email' => "report#send_email"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
