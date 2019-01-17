class HomeController < ApplicationController
  def index
    if current_school.blank?
      render 'pupilfirst', layout: 'tailwind'
    else
      @skip_container = true
      @sitewide_notice = true if %w[startupvillage.in].include?(params[:redirect_from])
      @hide_nav_links = false

      render layout: 'home'
    end
  end

  def story
    @skip_container = true
    render layout: 'application'
  end

  def fb
    @skip_container = true
    @hide_layout_header = true
    @auto_open = params[:apply].present?.to_s
    render layout: 'application'
  end

  def ios
    @skip_container = true
    @hide_layout_header = true

    if current_user.present?
      flash[:alert] = 'You are already signed in.'
      redirect_to root_url
    else
      @form = UserSignInForm.new(Reform::OpenForm.new)
      render layout: 'application'
    end
  end

  def sastra
    @skip_container = true
    @hide_layout_header = true

    if current_user.present?
      flash[:alert] = 'You are already signed in.'
      redirect_to root_url
    else
      @form = UserSignInForm.new(Reform::OpenForm.new)
      render layout: 'application'
    end
  end

  def pupilfirst
    @skip_container = true
    @hide_layout_header = true
    render layout: 'tailwind'
  end

  # GET /tour
  def tour
    @skip_container = true
    render layout: 'application'
  end

  # GET /policies/privacy
  def privacy
    privacy_policy = File.read(File.absolute_path(Rails.root.join('privacy_policy.md')))
    @privacy_policy_html = Kramdown::Document.new(privacy_policy).to_html.html_safe

    respond_to do |format|
      format.json { render json: { policy: @privacy_policy_html } }
      format.html
    end
  end

  # GET /policies/terms
  def terms
    terms_of_use = File.read(File.absolute_path(Rails.root.join('terms_of_use.md')))
    @terms_of_use_html = Kramdown::Document.new(terms_of_use).to_html.html_safe

    respond_to do |format|
      format.json { render json: { policy: @terms_of_use_html } }
      format.html
    end
  end

  # GET /oauth/:provider?from=FQDN&referer=
  def oauth
    # TODO: Consider validating the value of params[:from].
    set_cookie(:oauth_origin, params[:xyz])

    oauth_url_options = {
      host: "www.pupilfirst.#{Rails.env.production? ? 'com' : 'localhost'}",
      origin: params[:referer]
    }

    oauth_url = case params[:provider]
      when 'developer'
        user_developer_omniauth_authorize_url(oauth_url_options)
      when 'google'
        user_google_oauth2_omniauth_authorize_url(oauth_url_options)
      when 'facebook'
        user_facebook_omniauth_authorize_url(oauth_url_options)
      when 'github'
        user_github_omniauth_authorize_url(oauth_url_options)
      else
        raise "Invalid provider #{params[:provider]} supplied to oauth redirection route."
    end

    redirect_to oauth_url
  end

  # GET /oauth_unknown?email=
  def oauth_unknown
    flash[:notice] = "Your email address: #{params[:email]} is unregistered."
    redirect_to new_user_session_path
  end

  protected

  def background_image_number
    @background_image_number ||= begin
      session[:background_image_number] ||= rand(1..4)
      session[:background_image_number] += 1
      session[:background_image_number] = 1 if session[:background_image_number] > 4
      session[:background_image_number]
    end
  end

  def hero_text_alignment
    @hero_text_alignment ||= begin
      {
        1 => 'center',
        2 => 'right',
        3 => 'right',
        4 => 'right'
      }[background_image_number]
    end
  end

  helper_method :background_image_number
  helper_method :hero_text_alignment
end
