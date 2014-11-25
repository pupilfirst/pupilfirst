APP_CONFIG = {
  sms_provider_url: ENV['SMS_PROVIDER_URL'],
  login_secret: ENV['LOGIN_SECRET'],
  sms_statistics_to: ENV['SMS_STATISTICS_TO'].try(:split, ',')
}.with_indifferent_access
