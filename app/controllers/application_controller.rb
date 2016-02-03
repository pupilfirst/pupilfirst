class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  after_filter :prepare_unobtrusive_flash
  before_filter :set_content_security_policy

  def raise_not_found
    fail ActionController::RoutingError, 'Not Found'
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      referer = session.delete :referer

      if referer
        referer
      elsif current_user.startup.present? && !current_user.startup.unready?
        startup_url(current_user.startup)
      else
        super
      end
    else
      super
    end
  end

  protected

  def feature_active?(feature)
    Rails.env.development? || Rails.env.test? || Feature.active?(feature, current_user)
  end

  helper_method :feature_active?

  def configure_permitted_parameters
    # allow collecting additional attributes while accepting invitation: https://github.com/scambra/devise_invitable
    devise_parameter_sanitizer.for(:accept_invitation).concat(
      [
        :first_name, :last_name, :gender, :born_on, :university_id, :roll_number, :unconfirmed_phone
      ]
    )
  end

  # Set headers for CSP. Be careful when changing this.
  def set_content_security_policy
    image_sources = "img-src 'self' data: " + [
      'https://www.google-analytics.com https://blog.sv.co https://www.startatsv.com http://www.startatsv.com',
      'https://sv-assets.sv.co https://secure.gravatar.com https://uploaded-assets.sv.co hn.inspectlet.com'
    ].join(' ') + ';'

    resource = { media: 'https://s3.amazonaws.com/uploaded-assets-sv-co/' }
    typeform = { frame: 'https://svlabs.typeform.com' }
    slideshare = { frame: 'slideshare.net *.slideshare.net' }
    speakerdeck = { frame: 'speakerdeck.com *.speakerdeck.com' }

    csp_directives = [
      image_sources,
      script_sources,
      "style-src 'self' 'unsafe-inline' fonts.googleapis.com https://sv-assets.sv.co;",
      "connect-src 'self' hn.inspectlet.com wss://inspectletws.herokuapp.com;",
      "font-src 'self' fonts.gstatic.com https://sv-assets.sv.co;",
      'child-src https://www.youtube.com;',
      'frame-src https://www.youtube.com https://svlabs-public.herokuapp.com https://www.google.com ' \
        "#{typeform[:frame]} #{slideshare[:frame]} #{speakerdeck[:frame]};",
      "media-src 'self' #{resource[:media]};"
    ]

    response.headers['Content-Security-Policy'] = "default-src 'none'; " + csp_directives.join(' ')
  end

  private

  def script_sources
    recaptcha = 'www.google.com www.gstatic.com apis.google.com'

    "script-src 'self' https://ajax.googleapis.com https://www.google-analytics.com " \
      'https://blog.sv.co https://www.youtube.com http://www.startatsv.com https://sv-assets.sv.co ' \
      "cdn.inspectlet.com #{recaptcha};"
  end
end
