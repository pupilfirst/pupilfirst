class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception. Note that this is different from the default of :null_session.
  protect_from_forgery with: :exception

  before_action :sign_out_if_required
  before_action :store_user_location, if: :storable_location?
  before_action :redirect_to_primary_domain, if: :domain_redirection_required?

  around_action :set_time_zone, if: :current_user

  helper_method :avatar
  helper_method :current_host
  helper_method :current_school
  helper_method :current_founder
  helper_method :current_startup
  helper_method :current_coach
  helper_method :current_school_admin

  # When in production, respond to requests that ask for unhandled formats with 406.
  rescue_from ActionView::MissingTemplate do |exception|
    raise exception unless Rails.env.production?

    # Force format to HTML, because we don't have error pages for other format requests.
    request.format = 'html'

    raise ActionController::UnknownFormat, 'Not Acceptable'
  end

  # Pundit authorization error should cause a 404.
  rescue_from Pundit::NotAuthorizedError do |exception|
    if Rails.env.development?
      logger.error "Pundit::NotAuthorizedError: #{exception.message}"
      logger.error exception.backtrace.join("\n")
    end

    raise_not_found
  end

  # Redirect all requests from unknown domains to service homepage.
  rescue_from RequestFromUnknownDomain do
    redirect_to "https://www.pupilfirst.com?redirect_from=#{current_host}"
  end

  def raise_not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || dashboard_path
  end

  def current_host
    @current_host ||= Rails.env.test? ? 'test.host' : request.host
  end

  def current_domain
    @current_domain ||= Domain.find_by(fqdn: current_host)
  end

  # Returns the "resolved" school for a request.
  def current_school
    @current_school ||= if Rails.application.secrets.multitenancy
      resolved_school = current_domain&.school

      raise RequestFromUnknownDomain if resolved_school.blank?

      resolved_school
    else
      School.first
    end
  end

  def current_coach
    @current_coach ||= current_user&.faculty
  end

  def current_founder
    @current_founder ||= begin
      if current_user.present?
        founder_id = read_cookie(:founder_id)

        # Founders in current school for the user
        founders = current_user.founders

        # Try to select founder from value stored in cookie.
        founder = founder_id.present? ? founders.not_dropped_out.find_by(id: founder_id) : nil

        # Return selected founder, if any, or return the first founder (if any).
        founder.presence || founders.not_dropped_out.first
      end
    end
  end

  def current_startup
    @current_startup ||= current_founder&.startup
  end

  def current_school_admin
    @current_school_admin ||= begin
      if current_user.present? && current_school.present?
        current_user.school_admin
      end
    end
  end

  # sets a permanent signed cookie. Additional options such as :tld_length can be passed via the options_hash
  # eg: set_cookie(:token, 'abcd', { 'tld_length' => 1 })
  def set_cookie(key, value, options_hash = {})
    cookies.permanent.signed[key] = { value: value }.merge(options_hash)
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

  def pundit_user
    OpenStruct.new(
      current_user: current_user,
      current_founder: current_founder,
      current_school: current_school,
      current_coach: current_coach,
      current_school_admin: current_school_admin
    )
  end

  helper_method :pundit_user

  def api_token
    @api_token ||= begin
      header = request.headers['Authorization']&.strip

      # Authorization headers are of format "Authorization: <type> <credentials>".
      # We only care about the supplied credentials.
      header.split(' ')[-1] if header.present?
    end
  end

  def current_user
    if api_token.present?
      @current_user ||= Users::FindByApiTokenService.new(api_token, current_school).find
    else
      super
    end
  end

  private

  def set_time_zone(&block) # rubocop:disable Naming/AccessorMethodName
    Time.use_zone(current_user.time_zone, &block)
  end

  def sign_out_if_required
    service = ::Users::ManualSignOutService.new(self, current_user)
    service.sign_out_if_required
    redirect_to root_url if service.signed_out?
  end

  def authenticate_founder!
    # User must be logged in.
    authenticate_user!

    return if current_founder.present? && !current_founder.dropped_out?

    redirect_to root_path
  end

  def storable_location?
    non_html_response = destroy_user_session_path || is_a?(::TargetsController) && params[:action] == "details_v2"
    public_page = _process_action_callbacks.none? { |p| p.filter == :authenticate_user! }

    request.get? && is_navigational_format? && !request.xhr? && !public_page && !non_html_response
  end

  def store_user_location
    store_location_for(:user, request.fullpath)
  end

  def avatar(name, founder: nil, faculty: nil, version: :mid, background_shape: :circle)
    if faculty.present? && faculty.image.attached?
      return helpers.image_tag(faculty.image).html_safe
    end

    if founder.present? && founder.avatar.attached?
      return helpers.image_tag(founder.avatar_variant(version)).html_safe
    end

    Scarf::InitialAvatar.new(
      name,
      font_family: ['Source Sans Pro', 'sans-serif'],
      background_shape: background_shape
    ).svg.html_safe
  end

  def domain_redirection_required?
    return false if current_domain.blank?

    return false if current_domain.primary? || current_school.domains.one?

    !current_school.configuration['disable_primary_domain_redirection']
  end

  def redirect_to_primary_domain
    observable_redirect_to "#{request.ssl? ? 'https' : 'http'}://#{current_school.domains.primary.fqdn}#{request.path}"
  end
end
