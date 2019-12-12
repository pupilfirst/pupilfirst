class HomeController < ApplicationController
  def index
    @courses = current_school.courses.where(featured: true)
    render layout: 'student'
  end

  def styleguide
    @skip_container = true
    @hide_layout_header = true
    render layout: 'tailwind'
  end

  # GET /agreements/:agreement_type
  def agreement
    klass = case params[:agreement_type]
      when 'privacy-policy'
        SchoolString::PrivacyPolicy
      when 'terms-of-use'
        SchoolString::TermsOfUse
      else
        raise_not_found
    end

    @agreement_text = klass.for(current_school)

    raise_not_found if @agreement_text.blank?

    @agreement_type = klass.name.demodulize.titleize

    render layout: 'student'
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

    redirect_to OmniauthProviderUrlService.new(params[:provider], current_host).oauth_url
  end

  # GET /oauth_error?error=
  def oauth_error
    flash[:notice] = params[:error]
    redirect_to new_user_session_path
  end

  # GET /favicon.ico
  def favicon
    if current_school.present? && current_school.icon.attached?
      redirect_to view_context.url_for(current_school.icon_variant(:thumb))
    else
      redirect_to '/favicon.png'
    end
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
