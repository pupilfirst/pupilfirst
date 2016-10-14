APP_CONSTANTS = {
  coding_video_certificate_background_base64: Base64.strict_encode64(
    open(File.expand_path(File.join(Rails.root, 'app', 'assets', 'images', 'apply', 'batch_application', 'coding-video-certificate.png'))).read
  ),
  interview_certificate_background_base64: Base64.strict_encode64(
    open(File.expand_path(File.join(Rails.root, 'app', 'assets', 'images', 'apply', 'batch_application', 'interview-certificate.png'))).read
  )
}.with_indifferent_access
