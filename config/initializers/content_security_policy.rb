# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    def asset_host
      Rails.application.config.action_controller.asset_host
    end

    def facebook_csp
      { frame: 'https://www.facebook.com' }
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

    def recaptcha_csp
      { frame: 'https://www.recaptcha.net' }
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

    def jsdelivr_csp
      { style: 'cdn.jsdelivr.net', font: 'cdn.jsdelivr.net' }
    end

    def style_sources
      ['fonts.googleapis.com', jsdelivr_csp[:style], asset_host] - [nil]
    end

    def connect_sources
      sources = [rollbar_csp[:connect], *vimeo_csp[:connect]]
      sources += %w[ws://localhost:3036 ws://school.localhost:3036 ws://www.school.localhost:3036] if Rails.env.development?
      sources
    end

    def font_sources
      ['fonts.gstatic.com', jsdelivr_csp[:font], asset_host] - [nil]
    end

    def child_sources
      ['https://www.youtube.com']
    end

    def frame_sources
      [
        'https://www.google.com', youtube_csp[:frame], vimeo_csp[:frame], *slideshare_csp[:frame], *speakerdeck_csp[:frame], *google_form_csp[:frame], facebook_csp[:frame], recaptcha_csp[:frame], scribehow_csp[:frame]
      ]
    end

    def media_sources
      [*resource_csp[:media]]
    end

    def scribehow_csp
      { frame: 'https://scribehow.com' }
    end

    policy.default_src :none
    policy.img_src '*', :data, :blob
    policy.script_src :strict_dynamic, :unsafe_eval, :unsafe_inline, 'https:', 'http:'

    # Allow @vite/client to hot reload javascript changes in development
    policy.script_src(*policy.script_src, :unsafe_eval, "http://#{ ViteRuby.config.host_with_port }") if Rails.env.development?

    # You may need to enable this in production as well depending on your setup.
    policy.script_src(*policy.script_src, :blob) if Rails.env.test?

    policy.style_src :self, :unsafe_inline, *style_sources

    # Allow @vite/client to hot reload style changes in development
    policy.style_src(*policy.style_src, :unsafe_inline) if Rails.env.development?

    policy.connect_src :self, *connect_sources

    # Allow @vite/client to hot reload changes in development
    policy.connect_src(*policy.connect_src, "ws://#{ ViteRuby.config.host_with_port }") if Rails.env.development?

    policy.font_src :self, *font_sources
    policy.child_src(*child_sources)
    policy.frame_src :self, :data, *frame_sources
    policy.media_src :self, *media_sources, '* blob:'
    policy.object_src :self
    policy.worker_src :self
    policy.manifest_src :self
  end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
