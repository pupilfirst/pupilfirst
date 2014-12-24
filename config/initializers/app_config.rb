APP_CONFIG = {
  sms_provider_url: ENV['SMS_PROVIDER_URL'],
  login_secret: ENV['LOGIN_SECRET'],
  sms_statistics_all: ENV['SMS_STATISTICS_ALL'].try(:split, ','),
  sms_statistics_visakhapatnam: ENV['SMS_STATISTICS_VISAKHAPATNAM'].try(:split, ',')
}.with_indifferent_access
