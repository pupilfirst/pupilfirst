class Users::SessionsController < Devise::SessionsController
  # GET /resource/sign_in
  layout 'demo_generic_inner'

  def new
    # Store referer in session if it's sent.
    session[:referer] = params[:referer] if params[:referer].present?

    super
  end
end
