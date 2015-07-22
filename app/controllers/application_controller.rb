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

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:avatar, :twitter_url, :linkedin_url]
    # TODO
    # Unpermitted parameters: salutation, fullname, born_on(1i), born_on(2i), born_on(3i), is_student, college, course, semester
    devise_parameter_sanitizer.for(:sign_up).concat [:fullname]
    devise_parameter_sanitizer.for(:accept_invitation).concat [:salutation, :fullname, :email, :born_on, :is_student, :college_id, :course, :semester, :startup, :accept_startup]
  end

  def set_content_security_policy
    script_sources = "script-src 'self' https://ajax.googleapis.com https://www.google-analytics.com " +
      'https://blog.sv.co https://www.youtube.com;'
    image_sources = "img-src 'self' https://www.google-analytics.com https://blog.sv.co https://www.startatsv.com " +
      'http://svapp.assets.svlabs.in http://svapp-staging.assets.svlabs.in;'
    style_sources = "style-src 'self' 'unsafe-inline' fonts.googleapis.com;"
    connection_sources = "connect-src 'self';"
    font_sources = "font-src 'self' fonts.gstatic.com;"
    report_uri = "report-uri #{content_security_policy_report_url};"

    response.headers['Content-Security-Policy'] = "default-src 'none'; " +
      script_sources + image_sources + style_sources + connection_sources + font_sources + report_uri
    response.headers['Content-Security-Policy-Report-Only']
  end
end
