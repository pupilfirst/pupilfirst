module Users
  class SessionsController < Devise::SessionsController
    include Devise::Controllers::Rememberable
    before_action :skip_container, only: %i[new send_login_email]

    layout 'student', except: %i[token send_login_email create]

    # GET /user/sign_in
    def new
      if current_user.present?
        redirect_to after_sign_in_path_for(current_user)
      end
    end

    # POST /user/send_email - find or create user from email received
    def send_login_email
      @form = Users::Sessions::SignInWithEmailForm.new(Reform::OpenForm.new)
      @form.current_school = current_school

      if @form.validate(params[:session])
        @form.save(current_domain)
        render json: { error: nil }
      else
        render json: { error: @form.errors.full_messages.join(', ') }
      end
    end

    # POST /user/send_reset_password_email
    def send_reset_password_email
      @form = Users::Sessions::SendResetPasswordEmailForm.new(Reform::OpenForm.new)
      @form.current_school = current_school

      if @form.validate(params[:session])
        @form.save(current_domain)
        render json: { error: nil }
      else
        render json: { error: @form.errors.full_messages.join(', ') }
      end
    end

    # GET /user/token - link to sign_in user with token in params
    def token
      user = Users::AuthenticationService.new(params[:token]).authenticate

      if user.present?
        sign_in user
        remember_me(user) unless params[:shared_device] == 'true'
        Users::ConfirmationService.new(user).execute

        redirect_to after_sign_in_path_for(user)
      else
        redirect_to reset_password_path
      end
    end

    # GET /user/reset_password
    def reset_password
      user = User.find_by(reset_password_token: params[:token])
      if user.present?
        @token = params[:token]
      end
    end

    def update_password
      if current_user.present?
        redirect_to after_sign_in_path_for(current_user)
      else
        @form = Users::Sessions::ResetPasswordForm.new(Reform::OpenForm.new)
        if @form.validate(params[:session]) && @form.save
          sign_in @form.user
          render json: { error: nil, path: after_sign_in_path_for(current_user) }
        else
          render json: { error: @form.errors.full_messages.join(', ') }
        end
      end
    end

    # POST /user/sign_in
    def create
      @form = Users::Sessions::SignInWithPasswordForm.new(Reform::OpenForm.new)
      @form.current_school = current_school

      if @form.validate(params[:session])
        sign_in @form.user
        remember_me(@form.user) unless @form.shared_device?
        render json: { error: nil, path: after_sign_in_path_for(current_user) }
      else
        render json: { error: @form.errors.full_messages.join(', ') }
      end
    end

    private

    def skip_container
      @skip_container = true
    end
  end
end
