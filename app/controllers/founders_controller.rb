class FoundersController < ApplicationController
  before_filter :authenticate_founder!, except: :founder_profile

  def founder_profile
    @founder = Founder.friendly.find(params[:slug])
    @timeline = @founder.activity_timeline
    @skip_container = true
  end

  # GET /founders/:id/edit
  def edit
    @founder = current_founder
  end

  # PATCH /founders/:id
  def update
    @founder = Founder.find current_founder.id

    if @founder.update_attributes(founder_params)
      flash[:notice] = 'Profile updated'
      redirect_to founder_profile_path(slug: @founder.slug)
    else
      render 'edit'
    end
  end

  # PATCH /founder/update_password
  def update_password
    @founder = current_founder

    if @founder.update_with_password(founder_password_change_params)
      # Sign in the founder by passing validation in case his password changed
      sign_in @founder, bypass: true

      flash[:success] = 'Password updated'

      redirect_to founder_profile_path(slug: @founder.slug)
    else
      render 'edit'
    end
  end

  # GET /founder/phone
  def phone
    @skip_container = true
    session[:referer] = params[:referer] if params[:referer]
  end

  # PATCH /founder/set_unconfirmed_phone
  def set_unconfirmed_phone
    if current_founder.update(unconfirmed_phone: params[:founder][:unconfirmed_phone], verification_code_sent_at: nil)
      redirect_to phone_verification_founder_path
    else
      render 'phone'
    end
  end

  # GET /founder/phone_verification
  # rubocop:disable Metrics/CyclomaticComplexity
  def phone_verification
    @registration_ongoing = true if session[:registration_ongoing]
    @skip_container = true

    # skip to consent page if registration ongoing and founder already has a verified phone
    if @registration_ongoing && current_founder.phone.present?
      redirect_to create_startup_or_timeline_path, alert: 'You already have a verified phone number'
      return
    end

    # ask for a phone number if 'unconfirmed_phone' is missing
    unless current_founder.unconfirmed_phone.present?
      redirect_to phone_founder_path, alert: 'Please provide a phone number to verify!'
      return
    end

    # avoid code being re-generated if url is repeatedly hit
    code_sent_at = current_founder.verification_code_sent_at
    return if code_sent_at&. > 5.minute.ago

    # Generate a 6-digit verification code to send to the phone number.
    code, phone_number = current_founder.generate_phone_number_verification_code!

    return if Rails.env.development?

    # SMS the code to the phone number. Currently uses FA format.
    RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for SV.CO: #{code}", msisdn: phone_number)
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # PATCH /founder/resend
  def resend
    @registration_ongoing = true if session[:registration_ongoing]
    @skip_container = true

    code_sent_at = current_founder.verification_code_sent_at
    if code_sent_at&. > 5.minute.ago
      @retry_after_some_time = true
    else
      @retry_after_some_time = false
      code, phone_number = current_founder.generate_phone_number_verification_code!

      unless Rails.env.development?
        RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for SV.CO: #{code}", msisdn: phone_number)
      end

      @resent_verification_code = true
    end

    render 'phone_verification'
  end

  # POST /founder/verify
  def verify
    @skip_container = true

    begin
      current_founder.verify_phone_number!(params[:phone_verification_code])
    rescue Exceptions::PhoneNumberVerificationFailed
      @failed_to_verify_phone_number = true
      @registration_ongoing = true if session[:registration_ongoing]
      render 'phone_verification'
      return
    end

    flash[:notice] = 'Your phone number is now verified!'

    if session[:registration_ongoing]
      session[:registration_ongoing] = nil
      redirect_to create_startup_or_timeline_path
    else
      referer = session.delete :referer
      redirect_to referer || root_url
    end
  end

  private

  # If founder's startup has already been created (by team lead), take him there. Otherwise, take him to consent screen.
  def create_startup_or_timeline_path
    if current_founder.startup.present?
      startup_path(current_founder.startup)
    elsif current_founder.startup_admin?
      new_founder_startup_path
    else
      root_path(redirect_from: 'registration')
    end
  end

  def founder_password_change_params
    params.required(:founder).permit(:current_password, :password, :password_confirmation)
  end

  def founder_params
    params.require(:founder).permit(
      :first_name, :last_name, :avatar, :slack_username, :skype_id, :identification_proof, :college_identification, :course, :semester, :year_of_graduation,
      :about, :twitter_url, :linkedin_url, :personal_website_url, :blog_url, :facebook_url, :angel_co_url, :github_url, :behance_url,
      :university_id, :roll_number, :born_on, :communication_address, roles: []
    )
  end
end
