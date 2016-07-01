class UserController < ApplicationController
  # collect email for user identification
  def identify
    @user = User.new
  end

  # create session for email received
  def login
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
end
