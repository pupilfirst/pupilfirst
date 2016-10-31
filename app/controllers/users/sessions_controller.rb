module Users
  class SessionsController < Devise::SessionsController
    layout 'application_v2', only: [:new]

    # GET /user/sign_in
    def new
      @skip_container = true
      super
    end

    # POST user/send_email - find or create user from email received
    def send_login_email
      @skip_container = true

      @user = User.where(email: params[:user][:email]).first_or_initialize

      if @user.save
        @user.send_login_email(params[:referer])

        render layout: 'application_v2'
      else
        # show errors
        render 'new', layout: 'application_v2'
      end
    end

    # GET /authenticate - link to sign_in user with token in params
    def authenticate
      if token_valid?
        sign_in @user
        redirect_to after_sign_in_path_for(@user)
      else
        # Show error and ask for re-authentication
        flash[:error] = 'Something went wrong while signing you in! Please try again.'
        redirect_to new_user_session_path(referer: params[:referer])
      end
    end

    private

    def token_valid?
      @user = User.find_by(login_token: params[:token])
    end
  end
end
