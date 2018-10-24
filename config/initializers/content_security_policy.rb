# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  def google_analytics_csp
    {
      script: 'https://www.google-analytics.com',
      connect: 'https://www.google-analytics.com'
    }
  end

  def inspectlet_csp
    {
      connect: %w[https://hn.inspectlet.com wss://ws.inspectlet.com],
      script: 'https://cdn.inspectlet.com'
    }
  end

  def facebook_csp
    { script: 'https://connect.facebook.net', frame: 'https://www.facebook.com' }
  end

  def gtm_csp
    {
      script: %w[https://www.googletagmanager.com https://tagmanager.google.com/debug https://tagmanager.google.com/debug/],
      style: 'https://tagmanager.google.com/debug/'
    }
  end

  def instamojo_csp
    {
      script: 'https://js.instamojo.com/v1/checkout.js',
      frame: %w[https://test.instamojo.com/ https://www.instamojo.com/]
    }
  end

  def recaptcha_csp
    { script: %w[https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/] }
  end

  def cloudflare_csp
    { script: 'https://ajax.cloudflare.com/' }
  end

  def typeform_csp
    { frame: 'https://svlabs.typeform.com', script: %w[https://embed.typeform.com https://admin.typeform.com] }
  end

  # rubocop:disable Metrics/LineLength
  def intercom_csp
    {
      connect: %w[https://api.intercom.io https://api-iam.intercom.io https://api-ping.intercom.io https://nexus-websocket-a.intercom.io https://nexus-websocket-b.intercom.io https://nexus-long-poller-a.intercom.io https://nexus-long-poller-b.intercom.io wss://nexus-websocket-a.intercom.io wss://nexus-websocket-b.intercom.io https://uploads.intercomcdn.com https://uploads.intercomusercontent.com https://app.getsentry.com],
      child: %w[https://share.intercom.io https://intercom-sheets.com https://www.youtube.com https://player.vimeo.com https://fast.wistia.net],
      font: 'https://js.intercomcdn.com',
      media: 'https://js.intercomcdn.com',
      script: %w[https://app.intercom.io https://widget.intercom.io https://js.intercomcdn.com]
    }
  end
  # rubocop:enable Metrics/LineLength

  def slideshare_csp
    { frame: %w[slideshare.net *.slideshare.net] }
  end

  def speakerdeck_csp
    { frame: %w[speakerdeck.com *.speakerdeck.com] }
  end

  def google_form_csp
    { frame: %w[google.com *.google.com] }
  end

  def resource_csp
    { media: %w[https://s3.amazonaws.com/private-assets-sv-co/ https://public-assets.sv.co/] }
  end

  def youtube_csp
    { frame: 'https://www.youtube.com' }
  end

  def script_sources
    [
      'https://ajax.googleapis.com', 'https://blog.sv.co', 'https://www.youtube.com',
      'https://s.ytimg.com', 'http://www.startatsv.com', 'https://sv-assets.sv.co',
      google_analytics_csp[:script], inspectlet_csp[:script], facebook_csp[:script],
      *gtm_csp[:script], instamojo_csp[:script], *recaptcha_csp[:script], cloudflare_csp[:script],
      *typeform_csp[:script], *intercom_csp[:script]
    ]
  end

  def style_sources
    ['fonts.googleapis.com', 'https://sv-assets.sv.co', gtm_csp[:style]]
  end

  def connect_sources
    sources = [*inspectlet_csp[:connect], *intercom_csp[:connect], google_analytics_csp[:connect]]
    sources += %w[http://localhost:3035 ws://localhost:3035] if Rails.env.development?
    sources
  end

  def font_sources
    ['fonts.gstatic.com', 'https://sv-assets.sv.co', intercom_csp[:font]]
  end

  def child_sources
    ['https://www.youtube.com', *intercom_csp[:child]]
  end

  def frame_sources
    [
      'https://sv-co-public-slackin.herokuapp.com', 'https://www.google.com',
      typeform_csp[:frame], youtube_csp[:frame], *slideshare_csp[:frame], *speakerdeck_csp[:frame],
      *google_form_csp[:frame], facebook_csp[:frame], *instamojo_csp[:frame]
    ]
  end

  def media_sources
    [*resource_csp[:media], intercom_csp[:media]]
  end

  policy.default_src :none
  policy.img_src     '*', :data, :blob
  policy.script_src  :self, :unsafe_eval, *script_sources
  policy.style_src   :self, :unsafe_inline, *style_sources
  policy.connect_src :self, *connect_sources
  policy.font_src    :self, *font_sources
  policy.child_src(*child_sources)
  policy.frame_src :data, *frame_sources
  policy.media_src :self, *media_sources
  policy.object_src :self
end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
