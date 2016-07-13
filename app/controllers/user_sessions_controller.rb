class UserSessionsController < ApplicationController
  # GET user_sessions/new - collect email for user identification
  def new
    # save the referer
    session[:referer] = params[:referer]

    # validate token in params, if present
    if params[:token].present? && token_valid?
      save_token_and_redirect
      return
    end

    @user = User.new

    @skip_container = true
    render layout: 'application_v2'
  end

  # POST user_sessions/send_email - find or create user from email received
  def send_email
    @skip_container = true

    @user = User.where(email: params[:user][:email]).first_or_initialize
    @user.referer = session.delete :referer

    if @user.save
      @user.send_login_email

      render layout: 'application_v2'
    else
      # show errors
      render 'new', layout: 'application_v2'
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

  def redirect_to_referer
    referer = session.delete :referer
    redirect_to referer
  end
end
