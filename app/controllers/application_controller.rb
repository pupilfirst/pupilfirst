class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  after_filter :prepare_unobtrusive_flash
  before_filter :set_content_security_policy

  def raise_not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def after_sign_in_path_for(resource)
    referer = session.delete :referer
    referer ? referer : super
  end

  protected

  def feature_active?(feature)
    (Rails.env == "development") ||
      (Rails.env == "staging") ||
      (DbConfig.feature_active? feature, current_user)
  end
  helper_method :feature_active?

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:avatar, :twitter_url, :linkedin_url]
    # TODO
    # Unpermitted parameters: salutation, fullname, born_on(1i), born_on(2i), born_on(3i), is_student, college, course, semester
    devise_parameter_sanitizer.for(:sign_up).concat [:fullname]
    devise_parameter_sanitizer.for(:accept_invitation).concat [:salutation, :fullname, :email, :born_on, :is_student, :college_id, :course, :semester, :startup, :accept_startup]
  end

  def set_content_security_policy
    image_sources = "img-src 'self' https://www.google-analytics.com https://blog.sv.co https://www.startatsv.com " +
      'http://www.startatsv.com https://assets.sv.co'
    image_sources += ' http://svapp.assets.svlabs.in' if Rails.env.production?
    image_sources += ' http://svapp-staging.assets.svlabs.in' if Rails.env == 'staging'
    image_sources += ';'

    csp_directives = [
      image_sources,
      "script-src 'self' https://ajax.googleapis.com https://www.google-analytics.com " +
        'https://blog.sv.co https://www.youtube.com http://www.startatsv.com https://assets.sv.co;',
      "style-src 'self' 'unsafe-inline' fonts.googleapis.com https://assets.sv.co;",
      "connect-src 'self';",
      "font-src 'self' fonts.gstatic.com https://assets.sv.co;",
      'child-src https://www.youtube.com;',
      'frame-src https://www.youtube.com;'
    ]

    response.headers['Content-Security-Policy'] = "default-src 'none'; " + csp_directives.join(' ')
  end
end
