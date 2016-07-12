class UserSessionsController < ApplicationController
  # GET user_sessions/new - collect email for user identification
  def new
    # save the referer
    session[:referer] = params[:referer]

    # validate token in params, if present
    save_token_and_redirect if params[:token].present? && token_valid?

    @user = User.new
  end

  # POST user_sessions/send_email - find or create user from email received
  def send_email
    @user = User.where(email: params[:user][:email]).first_or_initialize
    @user.assign_attributes(name: params[:user][:name], phone: params[:user][:phone], university_id: params[:user][:university_id])
    if @user.save
      # email referer url with token attached
      @referer = session.delete :referer
      send_email_with_token

      @skip_container = true
      render layout: 'application_v2'
    else
      # show errors
      render 'new'
    end
  end

  private

  def save_token_and_redirect
    save_token
    redirect_to_referer
  end

  def token_valid?
    @user = User.find_by(login_token: params[:token])
  end

  def save_token
    set_cookie(:login_token, @user.login_token)
  end

  def send_email_with_token
    UserSessionMailer.send_login_token(@user, @referer).deliver_later
  end

  def redirect_to_referer
    referer = session.delete :referer
    redirect_to referer
  end
end
