Apipie.configure do |config|
  config.app_name                = "Svapp"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/v1/*.rb"
    config.authenticate = Proc.new do
     authenticate_or_request_with_http_basic do |username, password|
       username == "admin" && password == "password"
    end
  end
end
