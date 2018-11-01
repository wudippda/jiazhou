Apipie.configure do |config|
  config.app_name                = "Jiazhou"
  config.api_base_url            = ""
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.api_routes = Rails.application.routes
  config.translate = false
  config.app_info["1.0"] = "API document for Jiazhou 1.0"
end
