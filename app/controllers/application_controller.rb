class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  after_filter :prepare_unobtrusive_flash
  before_filter :set_content_security_policy
  before_action :prepare_platform_feedback

  # When in production, respond to requests that ask for unhandled formats with 406.
  rescue_from ActionView::MissingTemplate do |exception|
    raise exception unless Rails.env.production?

    # Force format to HTML, because we don't have error pages for other format requests.
    request.format = 'html'

    raise ActionController::UnknownFormat, 'Not Acceptable'
  end

  def raise_not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(Founder)
      referer = session.delete :referer

      if referer
        referer
      elsif current_founder.startup.present?
        startup_url(current_founder.startup)
      else
        super
      end
    else
      super
    end
  end

  # If a user is signed in, prepare a platform_feedback object to be used with its form
  def prepare_platform_feedback
    return unless current_founder

    @platform_feedback_for_form = PlatformFeedback.new(founder_id: current_founder.id)
  end

  protected

  def feature_active?(feature)
    Rails.env.development? || Rails.env.test? || Feature.active?(feature, current_founder)
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
    response.headers['Content-Security-Policy'] = ("default-src 'none'; " + csp_directives.join(' '))
  end

  private

  def csp_directives
    [
      image_sources,
      script_sources,
      "style-src 'self' 'unsafe-inline' fonts.googleapis.com https://sv-assets.sv.co;",
      "connect-src 'self' hn.inspectlet.com wss://inspectletws.herokuapp.com;",
      "font-src 'self' fonts.gstatic.com https://sv-assets.sv.co;",
      'child-src https://www.youtube.com;',
      frame_sources,
      "media-src 'self' #{resource_csp[:media]};"
    ]
  end

  def resource_csp
    { media: 'https://s3.amazonaws.com/private-assets-sv-co/' }
  end

  def typeform_csp
    { frame: 'https://svlabs.typeform.com' }
  end

  def slideshare_csp
    { frame: 'slideshare.net *.slideshare.net' }
  end

  def speakerdeck_csp
    { frame: 'speakerdeck.com *.speakerdeck.com' }
  end

  def google_form_csp
    { frame: 'google.com *.google.com' }
  end

  def recaptcha_csp
    { script: 'www.google.com www.gstatic.com apis.google.com' }
  end

  def youtube_csp
    { frame: 'https://www.youtube.com' }
  end

  def frame_sources
    <<~FRAME_SOURCES.squish
      frame-src
      #{youtube_csp[:frame]} https://svlabs-public.herokuapp.com https://www.google.com #{typeform_csp[:frame]}
      #{slideshare_csp[:frame]} #{speakerdeck_csp[:frame]} #{google_form_csp[:frame]};
    FRAME_SOURCES
  end

  def image_sources
    <<~IMAGE_SOURCES.squish
      img-src
      'self' data: https://www.google-analytics.com https://blog.sv.co http://www.startatsv.com https://sv-assets.sv.co
      https://secure.gravatar.com https://uploaded-assets.sv.co hn.inspectlet.com;
    IMAGE_SOURCES
  end

  def script_sources
    <<~SCRIPT_SOURCES.squish
      script-src
      'self' 'unsafe-eval' https://ajax.googleapis.com https://www.google-analytics.com https://blog.sv.co https://www.youtube.com
      http://www.startatsv.com https://sv-assets.sv.co cdn.inspectlet.com #{recaptcha_csp[:script]};
    SCRIPT_SOURCES
  end
end
