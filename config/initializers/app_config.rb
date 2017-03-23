APP_CONSTANTS = {
  certificate_background_base64: Base64.strict_encode64(open(File.expand_path(Rails.root.join('app', 'assets', 'images', 'apply', 'batch_application', 'coding-video-certificate.png'))).read)
}.with_indifferent_access
