module Users
  class SessionsController < Devise::SessionsController
    include Devise::Controllers::Rememberable

    before_action :skip_container, only: %i(new send_login_email)

    layout 'application_v2'

    # GET /user/sign_in
    def new
      if current_user.present?
        flash[:alert] = 'You are already signed in.'
        redirect_to root_url
      else
        form_data = OpenStruct.new(referer: params[:referer])
        @form = UserSignInForm.new(form_data)
      end
    end

    # POST /user/send_email - find or create user from email received
    def send_login_email
      @form = UserSignInForm.new(OpenStruct.new)
      if @form.validate(sign_in_params)
        @form.save
      else
        @sign_in_error = true
        render 'new'
      end
    end

    # GET /user/token - link to sign_in user with token in params
    def token
      response = Users::AuthenticationService.authenticate_token(params[:token])
      if response[:success]
        @user = User.find(response[:user_id])

        sign_in @user
        remember_me @user unless params[:shared_device] == 'true'
        Users::ConfirmationService.new(@user).execute

        flash[:success] = response[:message]
        redirect_to after_sign_in_path_for(@user)
      else
        # Show error and ask for re-authentication
        flash[:error] = response[:message]
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

    def sign_in_params
      params.require(:user_sign_in).permit(:email, :referer, :shared_device)
    end
  end
end
