class HomeController < ApplicationController
  skip_forgery_protection only: %i[service_worker]

  def index
    @courses = current_school.courses.where(featured: true)
    render layout: "student"
  end

  # GET /styleguide
  def styleguide
    # noop
  end

  # GET /agreements/:agreement_type
  def agreement
    klass =
      case params[:agreement_type]
      when "privacy-policy"
        SchoolString::PrivacyPolicy
      when "terms-and-conditions"
        SchoolString::TermsAndConditions
      when "code-of-conduct"
        SchoolString::CodeOfConduct
      else
        raise_not_found
      end

    @agreement_text = klass.for(current_school)

    raise_not_found if @agreement_text.blank?

    @agreement_type =
      case klass.name.demodulize.titleize
      when "Privacy Policy"
        t(".privacy_policy")
      when "Terms and Conditions"
        t(".terms_and_conditions")
      when "Code of Conduct"
        t("shared.code_of_conduct")
      end

    render layout: "student"
  end

  # GET /oauth/:provider?fqdn=FQDN&referrer=
  def oauth
    # Disallow routing OAuth results to unknown domains.
    if Domain.find_by(fqdn: params[:fqdn]).blank? || params[:session_id].blank?
      raise_not_found
    end

    set_cookie(
      :oauth_origin,
      {
        provider: params[:provider],
        fqdn: params[:fqdn],
        session_id: params[:session_id],
        link_data: params[:link_data]
      }.to_json
    )

    redirect_to OmniauthProviderUrlService.new(
                  params[:provider],
                  current_host
                ).oauth_url
  end

  # GET /oauth_error?error=
  def oauth_error
    flash[:notice] = params[:error]
    redirect_to new_user_session_path
  end

  # GET /favicon.ico
  def favicon
    if current_school.present? && current_school.icon_on_light_bg.attached?
      redirect_to(
        view_context.rails_public_blob_url(current_school.icon_variant(:thumb)),
        allow_other_host: true
      )
    else
      redirect_to "/favicon.png"
    end
  end

  # GET /service-worker.js
  def service_worker
    render layout: false, content_type: "text/javascript"
  end

  # GET /manifest.json
  def manifest
    render json: GenerateManifestService.new(current_school).json,
           content_type: "application/json"
  end

  # GET /offline
  def offline
    render layout: false
  end

  protected

  def background_image_number
    @background_image_number ||=
      begin
        session[:background_image_number] ||= rand(1..4)
        session[:background_image_number] += 1
        session[:background_image_number] = 1 if session[
          :background_image_number
        ] > 4
        session[:background_image_number]
      end
  end

  def hero_text_alignment
    @hero_text_alignment ||=
      begin
        { 1 => "center", 2 => "right", 3 => "right", 4 => "right" }[
          background_image_number
        ]
      end
  end

  helper_method :background_image_number
  helper_method :hero_text_alignment
end
