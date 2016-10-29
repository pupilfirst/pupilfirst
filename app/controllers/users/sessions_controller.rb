module Users
  class SessionsController < Devise::SessionsController
    layout 'application_v2', only: [:new]

    # GET /user/sign_in
    def new
      # Store referer in session if it's sent.
      save_referer if params[:referer]

      @skip_container = true
      super
    end

    # POST user/send_email - find or create user from email received
    def send_login_email
      @skip_container = true

      @user = User.where(email: params[:user][:email]).first_or_initialize

      if @user.save
        @user.send_login_email(session.delete(:referer))

        render layout: 'application_v2'
      else
        # show errors
        render 'new', layout: 'application_v2'
      end
    end

    def login_with_token
      # TODO
      redirect_to root_path
    end

    private

    def save_referer
      session[:referer] = params[:referer]
    end
  end
end
