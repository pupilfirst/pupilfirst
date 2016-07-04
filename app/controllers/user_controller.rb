class UserController < ApplicationController
  # try to authenticate user from cookie or given token
  def authentication
    if cookie[:login_token].present?
      set_current_user
      redirect_to params[:referrer]
    elsif params[:token].present?
      if token_valid?
        login_user
      else
        request_identification
      end
    end
  end

  # collect email for user identification
  def identify
    @user = User.new
  end

  # create session for email received
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
      @user.errors[:email] << 'does not look like a valid email'
      false
    end
  end
end
