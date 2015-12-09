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
    # TODO: Clean this method up. What is this about, anyway?!
    devise_parameter_sanitizer.for(:accept_invitation).concat [:avatar, :twitter_url, :linkedin_url]
    # Unpermitted parameters: salutation, fullname, born_on(1i), born_on(2i), born_on(3i), is_student, college, course, semester
    devise_parameter_sanitizer.for(:sign_up).concat [:first_name, :last_name]
    devise_parameter_sanitizer.for(:accept_invitation).concat(
      [
        :salutation, :first_name, :last_name, :email, :born_on, :is_student, :college_id, :course, :semester, :startup, :accept_startup
      ]
    )
  end

  # Set headers for CSP. Be careful when changing this.
  def set_content_security_policy
    image_sources = "img-src 'self' " + [
      'https://www.google-analytics.com https://blog.sv.co https://www.startatsv.com http://www.startatsv.com',
      'https://assets.sv.co https://secure.gravatar.com https://uploaded-assets.sv.co hn.inspectlet.com'
    ].join(' ') + ';'

    recaptcha = { script: 'www.google.com www.gstatic.com apis.google.com' }
    resource = { media: 'https://s3.amazonaws.com/upload.assets.sv.co/' }

    csp_directives = [
      image_sources,
      "script-src 'self' https://ajax.googleapis.com https://www.google-analytics.com " \
        'https://blog.sv.co https://www.youtube.com http://www.startatsv.com https://assets.sv.co ' \
        "cdn.inspectlet.com #{recaptcha[:script]};",
      "style-src 'self' 'unsafe-inline' fonts.googleapis.com https://assets.sv.co;",
      "connect-src 'self' hn.inspectlet.com wss://inspectletws.herokuapp.com;",
      "font-src 'self' fonts.gstatic.com https://assets.sv.co;",
      'child-src https://www.youtube.com;',
      'frame-src https://www.youtube.com https://svlabs-public.herokuapp.com https://www.google.com;',
      "media-src 'self' #{resource[:media]};"
    ]

    response.headers['Content-Security-Policy'] = "default-src 'none'; " + csp_directives.join(' ')
  end
end
