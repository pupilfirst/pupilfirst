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

  def pupilfirst
    @skip_container = true
    @hide_layout_header = true
    render layout: 'tailwind'
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

  # GET /oauth/:provider?fqdn=FQDN&referer=
  def oauth
    # Disallow routing OAuth results to unknown domains.
    raise_not_found if Domain.find_by(fqdn: params[:fqdn]).blank?

    set_cookie(:oauth_origin, {
      provider: params[:provider],
      fqdn: params[:fqdn],
      referer: params[:referer]
    }.to_json)

    redirect_to oauth_url(params[:provider])
  end

  # GET /oauth_error?error=
  def oauth_error
    flash[:notice] = params[:error]
    redirect_to new_user_session_path
  end

  protected

  def oauth_url(provider)
    url_opts = {
      host: "www.pupilfirst.#{Rails.env.production? ? 'com' : 'localhost'}"
    }

    case provider
      when 'developer'
        user_developer_omniauth_authorize_url(url_opts)
      when 'google'
        user_google_oauth2_omniauth_authorize_url(url_opts)
      when 'facebook'
        user_facebook_omniauth_authorize_url(url_opts)
      when 'github'
        user_github_omniauth_authorize_url(url_opts)
      else
        raise "Invalid provider #{provider} supplied to oauth redirection route."
    end
  end

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
