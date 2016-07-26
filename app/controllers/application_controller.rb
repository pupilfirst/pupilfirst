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

  def current_user
    @current_user ||= User.find_by(login_token: read_cookie(:login_token))
  end

  protected

  # sets a permanent signed cookie. Additional options such as :tld_length can be passed via the options_hash
  # eg: set_cookie(:token, 'abcd', { 'tld_length' => 1 })
  def set_cookie(key, value, options_hash = {})
    domain = Rails.env.production? ? '.sv.co' : :all
    cookies.permanent.signed[key] = { value: value, domain: domain }.merge(options_hash)
  end

  # read a signed cookie
  def read_cookie(key)
    cookies.signed[key]
  end

  # Returns currently 'signed in' application founder.
  def current_batch_applicant
    @current_batch_applicant ||= begin
      return if cookies[:applicant_token].blank?
      BatchApplicant.find_by token: cookies[:applicant_token]
    end
  end

  def feature_active?(feature)
    Rails.env.development? || Rails.env.test? || Feature.active?(feature, current_founder)
  end

  helper_method :current_batch_applicant
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
      "style-src 'self' 'unsafe-inline' fonts.googleapis.com https://sv-assets.sv.co #{keyreply_csp[:style]} #{heapanalytics_csp[:style]};",
      "connect-src 'self' #{inspectlet_csp[:connect]} #{heapanalytics_csp[:connect]};",
      "font-src 'self' fonts.gstatic.com https://sv-assets.sv.co #{heapanalytics_csp[:font]};",
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

  def google_analytics_csp
    {
      image: 'https://www.google-analytics.com https://stats.g.doubleclick.net',
      script: 'https://www.google-analytics.com'
    }
  end

  def inspectlet_csp
    {
      connect: 'https://hn.inspectlet.com wss://ws.inspectlet.com',
      script: 'https://cdn.inspectlet.com',
      image: 'https://hn.inspectlet.com'
    }
  end

  def facebook_csp
    {
      image: 'https://www.facebook.com/tr/',
      script: 'https://connect.facebook.net'
    }
  end

  def heapanalytics_csp
    if Rails.env.development?
      {
        script: 'http://cdn.heapanalytics.com http://heapanalytics.com',
        image: 'http://heapanalytics.com',
        connect: 'http://heapanalytics.com',
        font: 'http://heapanalytics.com',
        style: 'http://heapanalytics.com'
      }
    else
      {
        script: 'https://cdn.heapanalytics.com https://heapanalytics.com',
        image: 'https://heapanalytics.com',
        connect: 'https://heapanalytics.com',
        font: 'https://heapanalytics.com',
        style: 'https://heapanalytics.com'
      }
    end
  end

  def keyreply_csp
    {
      image: 'https://keyreply.com',
      script: 'https://keyreply.com',
      style: 'https://keyreply.com'
    }
  end

  def frame_sources
    <<~FRAME_SOURCES.squish
      frame-src
      https://svlabs-public.herokuapp.com https://www.google.com
      #{typeform_csp[:frame]} #{youtube_csp[:frame]} #{slideshare_csp[:frame]} #{speakerdeck_csp[:frame]}
      #{google_form_csp[:frame]};
    FRAME_SOURCES
  end

  def image_sources
    <<~IMAGE_SOURCES.squish
      img-src
      'self' data: https://blog.sv.co http://www.startatsv.com https://sv-assets.sv.co https://secure.gravatar.com
      https://uploaded-assets.sv.co #{keyreply_csp[:image]}
      #{google_analytics_csp[:image]} #{inspectlet_csp[:image]} #{facebook_csp[:image]} #{heapanalytics_csp[:image]};
    IMAGE_SOURCES
  end

  def script_sources
    <<~SCRIPT_SOURCES.squish
      script-src
      'self' 'unsafe-eval' https://ajax.googleapis.com https://blog.sv.co https://www.youtube.com
      http://www.startatsv.com https://sv-assets.sv.co #{keyreply_csp[:script]}
      #{recaptcha_csp[:script]} #{google_analytics_csp[:script]} #{inspectlet_csp[:script]} #{facebook_csp[:script]}
      #{heapanalytics_csp[:script]};
    SCRIPT_SOURCES
  end
end
