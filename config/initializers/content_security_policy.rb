# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  def asset_host
    Rails.application.config.action_controller.asset_host
  end

  def facebook_csp
    { frame: 'https://www.facebook.com' }
  end

  def typeform_csp
    { frame: 'https://svlabs.typeform.com' }
  end

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
    { media: %w[https://s3.amazonaws.com/private-assets-sv-co/ https://public-assets.sv.co/ https://s3.amazonaws.com/uploads.pupilfirst.com/] }
  end

  def youtube_csp
    { frame: 'https://www.youtube.com' }
  end

  def vimeo_csp
    { connect: %w[*.cloud.vimeo.com *.tus.vimeo.com], frame: 'https://player.vimeo.com' }
  end

  def rollbar_csp
    { connect: 'https://api.rollbar.com' }
  end

  def style_sources
    ['fonts.googleapis.com', asset_host] - [nil]
  end

  def connect_sources
    sources = [rollbar_csp[:connect], *vimeo_csp[:connect]]
    sources += %w[http://localhost:3035 ws://localhost:3035] if Rails.env.development?
    sources
  end

  def font_sources
    ['fonts.gstatic.com', asset_host] - [nil]
  end

  def child_sources
    ['https://www.youtube.com']
  end

  def frame_sources
    [
      'https://sv-co-public-slackin.herokuapp.com', 'https://www.google.com',
      typeform_csp[:frame], youtube_csp[:frame], vimeo_csp[:frame], *slideshare_csp[:frame], *speakerdeck_csp[:frame],
      *google_form_csp[:frame], facebook_csp[:frame]
    ]
  end

  def media_sources
    [*resource_csp[:media]]
  end

  policy.default_src :none
  policy.img_src '*', :data, :blob
  policy.script_src :unsafe_eval, :unsafe_inline, :strict_dynamic, 'https:', 'http:'
  policy.style_src :self, :unsafe_inline, *style_sources
  policy.connect_src :self, *connect_sources
  policy.font_src :self, *font_sources
  policy.child_src(*child_sources)
  policy.frame_src :data, *frame_sources
  policy.media_src :self, *media_sources
  policy.object_src :self
  policy.worker_src :self
  policy.manifest_src :self
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
