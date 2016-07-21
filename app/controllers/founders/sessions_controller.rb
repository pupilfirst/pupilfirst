module Founders
  class SessionsController < Devise::SessionsController
    layout 'application_v2', only: [:new]
    # GET /resource/sign_in
    def new
      # Store referer in session if it's sent.
      session[:referer] = params[:referer] if params[:referer]

      super
    end
  end
end
