APP_CONFIG = {
  sms_provider_url: ENV['SMS_PROVIDER_URL'],
  google_analytics_tracking_id: ENV['GOOGLE_ANALYTICS_TRACKING_ID'],
  easyrtc_socket_url: ENV['EASYRTC_SOCKET_URL']
}.with_indifferent_access
