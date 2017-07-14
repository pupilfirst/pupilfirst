class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :paytm_callback

  def index
    @skip_container = true
    @sitewide_notice = true if %w[startupvillage.in registration].include?(params[:redirect_from])
    @hide_nav_links = false
    @instagram_images = Instagram.load_latest_images

    render layout: 'home'
  end

  def story
    @skip_container = true
    render layout: 'application_v2'
  end

  # GET /tour
  def tour
    @skip_container = true
    render layout: 'application_v2'
  end

  # GET /policies/privacy
  def privacy
    privacy_policy = File.read(File.absolute_path(Rails.root.join('privacy_policy.md')))
    @privacy_policy_html = Kramdown::Document.new(privacy_policy).to_html.html_safe

    respond_to do |format|
      format.json { render json: { policy: @privacy_policy_html } }
      format.html { render layout: 'application_v2' }
    end
  end

  # GET /policies/terms
  def terms
    terms_of_use = File.read(File.absolute_path(Rails.root.join('terms_of_use.md')))
    @terms_of_use_html = Kramdown::Document.new(terms_of_use).to_html.html_safe

    respond_to do |format|
      format.json { render json: { policy: @terms_of_use_html } }
      format.html { render layout: 'application_v2' }
    end
  end

  # TODO: Remove this route once PayTM is correctly configured with '/paytm/callback' as the redirect_url.
  def paytm_callback
    # There's nothing to load.
  end

  protected

  def background_image_number
    @background_image_number ||= begin
      session[:background_image_number] ||= rand(4) + 1
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
