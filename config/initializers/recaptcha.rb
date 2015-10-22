Recaptcha.configure do |config|
  config.public_key  = ENV['RECAPTCHA_PUBLIC_KEY']
  config.private_key = ENV['RECAPTCHA_PRIVATE_KEY']
  config.api_version = 'v2'
  config.use_ssl_by_default = true
end
