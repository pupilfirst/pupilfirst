class UsersController < ApplicationController
  before_filter :authenticate_user!, except: :founder_profile

  def founder_profile
    @user = User.friendly.find(params[:slug])
    @timeline = @user.activity_timeline
    @skip_container = true
  end

  # GET /users/:id/edit
  def edit
    @user = current_user
  end

  # PATCH /users/:id
  def update
    @user = User.find current_user.id

    if @user.update_attributes(user_params)
      flash[:notice] = 'Profile updated'
      redirect_to founder_profile_path(slug: @user.slug)
    else
      render 'edit'
    end
  end

  # PATCH /users/update_password
  def update_password
    @user = current_user

    if @user.update_with_password(user_password_change_params)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, bypass: true

      flash[:success] = 'Password updated'

      redirect_to founder_profile_path(slug: @user.slug)
    else
      render 'edit'
    end
  end

  # GET /users/:id/phone
  def phone
    session[:referer] = params[:referer] if params[:referer]
  end

  # POST /users/:id/code
  def code
    # Generate a 6-digit verification code to send to the phone number.
    @skip_container = true
    code, phone_number = begin
      current_user.generate_phone_number_verification_code(params[:phone_number])
    rescue Exceptions::InvalidPhoneNumber => e
      @failed_to_add_phone_number = e.message
      render 'phone'
      return
    end

    return if Rails.env.development?

    # SMS the code to the phone number. Currently uses FA format.
    RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for SV.CO: #{code}", msisdn: phone_number)
  end

  # PATCH /users/:id/resend
  def resend
    @skip_container = true
    if current_user.updated_at <= 5.minute.ago
      @retry_after_some_time = false
      code, phone_number = current_user.generate_phone_number_verification_code(current_user.unconfirmed_phone)

      unless Rails.env.development?
        RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for SV.CO: #{code}", msisdn: phone_number)
      end

      @resent_verification_code = true
    else
      @retry_after_some_time = true
    end

    render 'code'
  end

  # POST /users/:id/verify
  def verify
    @skip_container = true
    begin
      current_user.verify_phone_number(params[:phone_verification_code])
    rescue Exceptions::PhoneNumberVerificationFailed
      @failed_to_verify_phone_number = true
      render 'code'
      return
    end

    flash[:notice] = 'Your phone number is now verified!'

    referer = session.delete :referer
    redirect_to referer || root_url
  end

  private

  def user_password_change_params
    params.required(:user).permit(:current_password, :password, :password_confirmation)
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :avatar, :slack_username, :college_identification, :about,
      :twitter_url, :linkedin_url, :personal_website_url, :blog_url, :facebook_url, :angel_co_url, :github_url, :behance_url,
      :university_id, :roll_number, :born_on, :communication_address, roles: []
    )
  end
end
