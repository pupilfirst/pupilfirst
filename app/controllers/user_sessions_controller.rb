class UserSessionsController < ApplicationController
  # GET user/authenticate - try to authenticate user from given token
  def authentication
    params[:token].present? ? validate_token : request_email_for_authentication
  end

  # GET user_sessions/new - collect email for user identification
  def new
    @user = User.new
  end

  # POST user_sessions/send_email - find or create user from email received
  def send_email
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
    @user = User.where(email: params[:user_sessions][:email]).first_or_create
  end

  def send_email_with_token
    UserSessionMailer.send_login_token(@user, @referer).deliver_later
  end

  def email_valid?
    @user = User.new(params[:user_sessions].permit(:email))
    if params[:user_sessions][:email] =~ /@/
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
