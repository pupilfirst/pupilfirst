APP_CONFIG = {
  sms_provider_url: ENV['SMS_PROVIDER_URL'],
  google_analytics_tracking_id: ENV['GOOGLE_ANALYTICS_TRACKING_ID'],
  easyrtc_socket_url: ENV['EASYRTC_SOCKET_URL'],
  slack_token: ENV['SLACK_TOKEN'],
  instamojo: {
    url: ENV['INSTAMOJO_API_URL'],
    api_key: ENV['INSTAMOJO_API_KEY'],
    auth_token: ENV['INSTAMOJO_AUTH_TOKEN'],
    salt: ENV['INSTAMOJO_SALT']
  }
}.with_indifferent_access
