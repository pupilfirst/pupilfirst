class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by resetting user session. Note that this is different from the default of :exception.
  protect_from_forgery with: :reset_session

  # Activate pretender.
  impersonates :user

  before_action :prepare_platform_feedback, :set_content_security_policy
  after_action :prepare_unobtrusive_flash
  before_action :sign_out_if_required
  before_action :pretender

  helper_method :current_mooc_student
  helper_method :current_founder
  helper_method :current_startup

  # When in production, respond to requests that ask for unhandled formats with 406.
  rescue_from ActionView::MissingTemplate do |exception|
    raise exception unless Rails.env.production?

    # Force format to HTML, because we don't have error pages for other format requests.
    request.format = 'html'

    raise ActionController::UnknownFormat, 'Not Acceptable'
  end

  # Pundit authorization error should cause a 404.
  rescue_from Pundit::NotAuthorizedError, with: :raise_not_found

  def raise_not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  def after_sign_in_path_for(resource)
    referer = params[:referer] || session[:referer]

    if referer.present?
      referer
    elsif resource.is_a?(AdminUser)
      super
    else
      Users::AfterSignInPathResolverService.new(resource).after_sign_in_path
    end
  end

  # If a user is signed in, prepare a platform_feedback object to be used with its form
  def prepare_platform_feedback
    return unless current_founder

    @platform_feedback_for_form = PlatformFeedback.new(founder_id: current_founder.id)
  end

  def current_mooc_student
    @current_mooc_student ||= MoocStudent.find_by(user: current_user) if current_user.present?
  end

  def current_founder
    @current_founder ||= current_user&.founder
  end

  def current_startup
    @current_startup ||= current_founder&.startup
  end

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

  def feature_active?(feature)
    Feature.active?(feature, current_user)
  end

  helper_method :feature_active?

  # Set headers for CSP. Be careful when changing this.
  def set_content_security_policy
    response.headers['Content-Security-Policy'] = ("default-src 'none'; " + csp_directives.join(' '))
  end

  # Makes redirects observable from integration tests.
  def observable_redirect_to(url)
    if Rails.env.test?
      render plain: "If this wasn't an integration test, you'd be redirected to: #{url}"
    else
      redirect_to(url)
    end
  end

  def current_ability
    @current_ability ||= ::Ability.new(true_user)
  end

  private

  def require_active_subscription
    return if current_founder.subscription_active?
    flash[:error] = 'You do not have an active subscription. Please renew your subscription and try again.'
    redirect_to fee_founder_url
  end

  def sign_out_if_required
    service = ::Users::ManualSignOutService.new(self, current_user)
    service.sign_out_if_required
    redirect_to root_url if service.signed_out?
  end

  def authenticate_founder!
    # User must be logged in.
    authenticate_user!

    founder = current_user.founder
    return if founder.present? && !founder.exited?

    flash[:error] = 'You are not an active student anymore!' if founder&.exited?
    redirect_to root_path
  end

  def csp_directives
    [
      image_sources,
      script_sources,
      style_sources,
      connect_sources,
      font_sources,
      child_sources,
      frame_sources,
      media_sources,
      object_sources
    ]
  end

  def resource_csp
    { media: 'https://s3.amazonaws.com/private-assets-sv-co/ https://public-assets.sv.co/' }
  end

  def typeform_csp
    { frame: 'https://svlabs.typeform.com', script: 'https://embed.typeform.com https://admin.typeform.com' }
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

  def youtube_csp
    { frame: 'https://www.youtube.com' }
  end

  def google_analytics_csp
    {
      image: 'https://www.google-analytics.com https://stats.g.doubleclick.net https://www.google.com/pagead/ga-audiences',
      script: 'https://www.google-analytics.com',
      connect: 'https://www.google-analytics.com'
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
      image: 'https://www.facebook.com/tr/ https://scontent.xx.fbcdn.net',
      script: 'https://connect.facebook.net',
      frame: 'https://www.facebook.com'
    }
  end

  def gtm_csp
    {
      script: 'https://www.googletagmanager.com https://tagmanager.google.com/debug https://tagmanager.google.com/debug/',
      style: 'https://tagmanager.google.com/debug/'
    }
  end

  def instamojo_csp
    {
      script: 'https://js.instamojo.com/v1/checkout.js',
      frame: 'https://test.instamojo.com/ https://www.instamojo.com/'
    }
  end

  def recaptcha_csp
    {
      script: 'https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/'
    }
  end

  def cloudflare_csp
    {
      script: 'https://ajax.cloudflare.com/'
    }
  end

  def development_csp
    return {} unless Rails.env.development?

    {
      connect: 'http://localhost:3035 ws://localhost:3035'
    }
  end

  def child_sources
    <<~CHILD_SOURCES.squish
      child-src https://www.youtube.com;
    CHILD_SOURCES
  end

  def style_sources
    <<~STYLE_SOURCES.squish
      style-src 'self' 'unsafe-inline' fonts.googleapis.com https://sv-assets.sv.co
      #{gtm_csp[:style]};
    STYLE_SOURCES
  end

  def frame_sources
    <<~FRAME_SOURCES.squish
      frame-src
      data:
      https://sv-co-public-slackin.herokuapp.com https://www.google.com
      #{typeform_csp[:frame]} #{youtube_csp[:frame]} #{slideshare_csp[:frame]} #{speakerdeck_csp[:frame]}
      #{google_form_csp[:frame]} #{facebook_csp[:frame]} #{instamojo_csp[:frame]};
    FRAME_SOURCES
  end

  def image_sources
    <<~IMAGE_SOURCES.squish
      img-src * data: blob:;
    IMAGE_SOURCES
  end

  def script_sources
    <<~SCRIPT_SOURCES.squish
      script-src
      'self' 'unsafe-eval' 'unsafe-inline' https://ajax.googleapis.com https://blog.sv.co https://www.youtube.com
      https://s.ytimg.com http://www.startatsv.com https://sv-assets.sv.co
      #{google_analytics_csp[:script]} #{inspectlet_csp[:script]} #{facebook_csp[:script]}
      #{gtm_csp[:script]} #{instamojo_csp[:script]} #{recaptcha_csp[:script]} #{cloudflare_csp[:script]}
      #{typeform_csp[:script]};
    SCRIPT_SOURCES
  end

  def connect_sources
    <<~CONNECT_SOURCES.squish
      connect-src 'self' #{inspectlet_csp[:connect]}
      #{google_analytics_csp[:connect]} #{development_csp[:connect]};
    CONNECT_SOURCES
  end

  def font_sources
    <<~FONT_SOURCES.squish
      font-src 'self' fonts.gstatic.com https://sv-assets.sv.co;
    FONT_SOURCES
  end

  def media_sources
    <<~MEDIA_SOURCES.squish
      media-src 'self' #{resource_csp[:media]};
    MEDIA_SOURCES
  end

  def object_sources
    "object-src 'self';"
  end

  def pretender
    @pretender = true if current_user != true_user
  end

  def avatar(name, founder: nil, version: :mid, background_shape: :circle)
    if founder.present? && founder.avatar? && !founder.avatar_processing?
      return helpers.image_tag(founder.avatar.public_send(version).url).html_safe
    end

    Scarf::InitialAvatar.new(
      name,
      font_family: ['Source Sans Pro', 'sans-serif'],
      background_shape: background_shape
    ).svg.html_safe
  end

  helper_method :avatar
end
