class UsersController < ApplicationController
  before_filter :authenticate_user!, only: [:show, :edit, :update]
  before_filter :restrict_to_current_user, only: [:show, :edit, :update]

  layout 'demo_generic_inner'

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = params[:id].present? ? User.find(params[:id]) : current_user
  end

  def update
    @user = User.find current_user.id

    if @user.update_attributes(user_params)
      flash[:notice] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def update_password
    @user = User.find current_user.id

    if @user.update_with_password(user_password_change_params)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, bypass: true

      flash[:notice] = 'Password updated'

      redirect_to @user
    else
      render 'edit'
    end
  end

  def new
  end

  def invite
    render layout: false
  end

  def send_invite
    @user = User.find_by_email(params[:user][:email]) rescue nil
    if @user.try(:startup).nil?
      @user = User.invite!(invite_params)
      @user.startup = Startup.find(session[:startup_id])
      @user.save!
    else
      @user.errors[:exist] = "this user is associated with other startup"
    end
  end

  def create
  end

  def enter_phone
  end

  def code
    # Generate a 6-digit verification code to send to the phone number.
    code, phone_number = begin
      current_user.generate_phone_number_verification_code(params[:phone_number])
    rescue Exceptions::InvalidPhoneNumber => e
      @failed_to_add_phone_number = e.message
      render 'phone' and return
    end

    # SMS the code to the phone number. Currently uses FA format.
    unless Rails.env.development?
      RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for SV: #{code}", msisdn: phone_number)
    end
  end

  def resend
    if (current_user.updated_at <= 5.minute.ago)
      @retry_after_some_time = false
      code, phone_number = current_user.generate_phone_number_verification_code(current_user.phone)

      unless Rails.env.development?
        RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for SV: #{code}", msisdn: phone_number)
      end

      @resent_verification_code = true
    else
      @retry_after_some_time = true
    end
    render 'code' and return
  end

  def verify
    begin
      current_user.verify_phone_number(current_user.phone, params[:phone_verification_code])
    rescue Exceptions::PhoneNumberVerificationFailed
      @failed_to_verify_phone_number = true
      render 'code' and return
    end
    flash[:notice] = 'Your phone number is now verified!'

    if session[:referer]
      session[:referer] = nil
    end

    referer = session.delete :referer

    redirect_to referer || root_url
  end

  private

  def invite_params
    params.require(:user).permit(:email, :fullname)
  end

  def user_password_change_params
    params.required(:user).permit(:current_password, :password, :password_confirmation)
  end

  def user_params
    params.require(:user).permit(:fullname, :twitter_url, :linkedin_url, :avatar, :title)
  end

  def restrict_to_current_user
    raise_not_found if current_user.id != params[:id].to_i
  end
end
