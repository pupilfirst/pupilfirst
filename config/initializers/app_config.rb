APP_CONFIG = {
  sms_provider_url: ENV['SMS_PROVIDER_URL'],
  login_secret: ENV['LOGIN_SECRET'],
  api_version: ENV['API_VERSION'],
  google_analytics_tracking_id: ENV['GOOGLE_ANALYTICS_TRACKING_ID'],
  application_tokens: ENV['APPLICATION_TOKENS'].try(:split, ',')
}.with_indifferent_access
