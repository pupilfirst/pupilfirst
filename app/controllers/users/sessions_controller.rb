module Users
  class SessionsController < ApplicationController
    layout 'application_v2'

    # GET /user/sign_in
    def new
      @skip_container = true
      form_data = OpenStruct.new(referer: params[:referer])
      @form = UserSignInForm.new(form_data)
    end

    # POST user/send_email - find or create user from email received
    def send_login_email
      @skip_container = true
      @form = UserSignInForm.new(OpenStruct.new)
      if @form.validate(sign_in_params)
        @form.save
      else
        render 'new'
      end
    end

    # GET /authenticate - link to sign_in user with token in params
    def authenticate
      response = UserAuthenticationService.authenticate_token(params[:token])
      if response[:success]
        @user = User.find(response[:user_id])
        sign_in @user
        flash[:success] = response[:message]
        redirect_to after_sign_in_path_for(@user)
      else
        # Show error and ask for re-authentication
        flash[:error] = response[:message]
        redirect_to new_user_session_path(referer: params[:referer])
      end
    end

    private

    def sign_in_params
      params.require(:user_sign_in).permit(:email, :referer, :shared_device)
    end
  end
end
