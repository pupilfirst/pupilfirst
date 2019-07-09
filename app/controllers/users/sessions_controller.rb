module Users
  class SessionsController < Devise::SessionsController
    include Devise::Controllers::Rememberable
    before_action :skip_container, only: %i[new send_login_email]

    layout 'student', except: %i[token send_login_email create]

    # GET /user/sign_in
    def new
      if current_user.present?
        flash[:alert] = 'You are already signed in.'
        redirect_to after_sign_in_path_for(current_user)
      else
        form_data = Reform::OpenForm.new(referer: params[:referer])
        @form = UserSignInForm.new(form_data)
      end
    end

    # POST /user/send_email - find or create user from email received
    def send_login_email
      @form = UserSignInForm.new(Reform::OpenForm.new)
      @form.current_school = current_school

      if @form.validate(params[:user_sign_in])
        @form.save(current_domain)
      else
        @sign_in_error = true
        render 'new'
      end
    end

    # GET /user/token - link to sign_in user with token in params
    def token
      user = Users::AuthenticationService.new(params[:token]).authenticate

      if user.present?
        sign_in user
        remember_me(user) unless params[:shared_device] == 'true'
        Users::ConfirmationService.new(user).execute

        flash[:success] = 'User authenticated successfully.'
        redirect_to after_sign_in_path_for(user)
      else
        # Show an error message.
        flash[:error] = 'User authentication failed. The link you followed appears to be invalid.'
        redirect_to new_user_session_path(referer: params[:referer])
      end
    end

    # POST /user/sign_in
    #
    # This route is disabled for the moment since we do not support logging in with password.
    def create
      raise_not_found
    end

    private

    def skip_container
      @skip_container = true
    end
  end
end
