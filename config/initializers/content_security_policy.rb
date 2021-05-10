# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  def asset_host_csp
    {
      font: [Rails.application.config.action_controller.asset_host],
      style: [Rails.application.config.action_controller.asset_host],
      connect: %w[*.s3.eu-west-3.amazonaws.com],
    }
  end

  def facebook_csp
    { frame: %w[https://www.facebook.com] }
  end

  def typeform_csp
    { frame: %w[https://form.typeform.com] }
  end

  def slideshare_csp
    { frame: %w[slideshare.net *.slideshare.net] }
  end

  def speakerdeck_csp
    { frame: %w[speakerdeck.com *.speakerdeck.com] }
  end

  def google_csp
    {
      frame: %w[google.com *.google.com],
      font: %w[fonts.gstatic.com],
      style: %w[fonts.googleapis.com],
    }
  end

  def resource_csp
    { media: %w[https://s3.amazonaws.com/private-assets-sv-co/ https://public-assets.sv.co/ https://s3.amazonaws.com/uploads.pupilfirst.com/] }
  end

  def youtube_csp
    {
      frame: %w[https://www.youtube.com],
      child: %w[https://www.youtube.com],
    }
  end

  def vimeo_csp
    { connect: %w[*.cloud.vimeo.com *.tus.vimeo.com], frame: 'https://player.vimeo.com' }
  end

  def rollbar_csp
    { connect: %w[https://api.rollbar.com] }
  end

  def newrelic_csp
    {
      script: %w[https://js-agent.newrelic.com https://*.nr-data.net],
      connect: %w[https://*.nr-data.net],
    }
  end

  def hotjar_csp
    {
      image: %w[http://*.hotjar.com https://*.hotjar.com http://*.hotjar.io https://*.hotjar.io],
      script: %w[http://*.hotjar.com https://*.hotjar.com http://*.hotjar.io https://*.hotjar.io],
      connect: %w[http://*.hotjar.com:* https://*.hotjar.com:* http://*.hotjar.io https://*.hotjar.io wss://*.hotjar.com],
      frame: %w[https://*.hotjar.com http://*.hotjar.io https://*.hotjar.io],
      font: %w[http://*.hotjar.com https://*.hotjar.com http://*.hotjar.io https://*.hotjar.io],
    }
  end

  def fullstory_csp
    {
      connect: %w[https://rs.fullstory.com],
      script: %w[https://edge.fullstory.com https://www.fullstory.com https://fullstory.com],
      imgage: %w[https://rs.fullstory.com],
    }
  end

  def usetiful_csp
    {
      srcipt: %w[usetiful.com *.usetiful.com],
      frame: %w[usetiful.com *.usetiful.com],
      connect: %w[usetiful.com *.usetiful.com],
    }
  end

  def heap_csp
    {
      script: %w[https://cdn.heapanalytics.com https://heapanalytics.com],
      imgage: %w[ https://heapanalytics.com],
      style: %w[https://heapanalytics.com],
      connect: %w[https://heapanalytics.com],
      font: %w[https://heapanalytics.com],
    }
  end

  def gtm_csp
    {
      script: %w[https://www.googletagmanager.com],
      image: %w[www.googletagmanager.com],
    }
  end

  def calendly_csp
    {
      style: %w[assets.calendly.com],
      frame: %w[https://calendly.com assets.calendly.com],
    }
  end

  def tribe_community_csp
    {
      frame: %w[https://community.growthtribe.io https://auth.growthtribe.io],
    }
  end

  def development_csp
    return {} unless Rails.env.development?

    {
      connect: %w[http://localhost:3035 ws://localhost:3035],
    }
  end

  def sources(kind)
    [
      asset_host_csp,
      facebook_csp,
      typeform_csp,
      slideshare_csp,
      speakerdeck_csp,
      google_csp,
      resource_csp,
      youtube_csp,
      vimeo_csp,
      rollbar_csp,
      newrelic_csp,
      hotjar_csp,
      fullstory_csp,
      usetiful_csp,
      heap_csp,
      gtm_csp,
      calendly_csp,
      tribe_community_csp,
      development_csp,
    ]
      .flat_map{|csp| csp[kind]}
      .compact
  end

  policy.default_src :none
  policy.img_src '*', :data, :blob, *sources(:image)
  policy.script_src :unsafe_eval, :unsafe_inline, 'https:', 'http:', *sources(:script)
  policy.style_src :self, :unsafe_inline, *sources(:style)
  policy.connect_src :self, *sources(:connect)
  policy.font_src :self, *sources(:font)
  policy.child_src :self, *sources(:child)
  policy.frame_src :data, *sources(:frame)
  policy.media_src :self, *sources(:media)
  policy.object_src :self
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
