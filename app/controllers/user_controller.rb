class UserController < ApplicationController
  # try to authenticate user from cookie or given token
  def authentication
    if cookies[:login_token].present?
      # something was wrong with the present cookie, clear it and authenticate again
      clear_cookie_and_authenticate
    else
      check_for_token_param
    end
  end

  # collect email for user identification
  def identify
    @user = User.new
  end

  # find or create user from email received
  def login
    # validate email
    unless email_valid?
      render 'identify'
      return
    end

    find_or_create_user

    # email referer url with token attached
    @referer = session.delete :referer
    send_email_with_token
  end

  private

  def clear_cookie_and_authenticate
    cookies[:login_token] = nil
    flash[:error] = 'Something seems wrong! Please sign in again'
    request_email_for_authentication
  end

  def check_for_token_param
    params[:token].present? ? validate_token : request_email_for_authentication
  end

  def validate_token
    token_valid? ? save_token_and_redirect_back : request_email_for_authentication
  end

  def save_token_and_redirect_back
    save_token
    redirect_to_referer
  end

  def token_valid?
    @user = User.find_by(login_token: params[:token])
  end

  def save_token
    cookies[:login_token] = { value: @user.login_token, expires: 2.months.from_now }
  end

  def request_email_for_authentication
    redirect_to user_identify_path
  end

  def find_or_create_user
    @user = User.where(email: params[:user][:email]).first_or_create
  end

  def send_email_with_token
    UserMailer.send_login_token(@user, @referer).deliver_later
  end

  def email_valid?
    @user = User.new(params[:user].permit(:email))
    if params[:user][:email] =~ /@/
      true
    else
      @user.errors[:email] << 'does not look like a valid address'
      false
    end
  end

  def redirect_to_referer
    referer = session.delete :referer
    redirect_to referer
  end
end
