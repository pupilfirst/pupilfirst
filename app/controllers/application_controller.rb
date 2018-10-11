class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by resetting user session. Note that this is different from the default of :exception.
  protect_from_forgery with: :reset_session

  # Activate pretender.
  impersonates :user

  before_action :prepare_platform_feedback
  after_action :prepare_unobtrusive_flash
  before_action :sign_out_if_required
  before_action :pretender

  helper_method :current_founder
  helper_method :current_startup
  helper_method :current_coach

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

  def current_coach
    @current_coach ||= current_user&.faculty
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

  def pretender
    @pretender = true if current_user != true_user
  end

  def avatar(name, founder: nil, faculty: nil, version: :mid, background_shape: :circle)
    if faculty.present? && faculty.image?
      return helpers.image_tag(faculty.image_url).html_safe
    end

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
