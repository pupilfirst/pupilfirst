module Users
  class SessionsController < Devise::SessionsController
    include Devise::Controllers::Rememberable
    include RecaptchaVerifiable
    before_action :must_have_current_school
    layout "student"

    # GET /users/sign_in?referrer
    def new
      store_location_for(:user, params[:referrer]) if params[:referrer].present?

      if current_user.present?
        flash[:notice] = t(".already_signed")
        redirect_to after_sign_in_path_for(current_user)
      end
    end

    # POST /user/send_reset_password_email
    def send_reset_password_email
      @form =
        Users::Sessions::SendResetPasswordEmailForm.new(Reform::OpenForm.new)
      @form.current_school = current_school

      recaptcha_success =
        recaptcha_success?(@form, action: "user_password_reset")

      unless recaptcha_success
        redirect_to sign_in_with_email_path(visible_recaptcha: 1)
        return
      end

      if @form.validate(params)
        @form.save
        render "email_sent", locals: { kind: :reset_password_link }
      else
        flash[:error] = @form.errors.full_messages.join(", ")
        redirect_to request_password_reset_path
      end
    end

    # GET /user/token?referrer - link to sign_in user with token in params
    def token
      user =
        Users::AuthenticationService.new(
          current_school,
          params[:token]
        ).authenticate
      store_location_for(:user, params[:referrer]) if params[:referrer].present?

      if user.present?
        sign_in user
        remember_me(user) unless params[:shared_device] == "true"
        Users::ConfirmationService.new(user).execute
        user.update!(account_deletion_notification_sent_at: nil)

        redirect_to after_sign_in_path_for(user)
      else
        flash[:error] = t(".link_expired")
        redirect_to new_user_session_path
      end
    end

    # GET /user/reset_password
    def reset_password
      @user = Users::ValidateResetTokenService.new(params[:token]).authenticate
      if @user.present?
        @token = params[:token]
      else
        flash[:error] = t(".link_used")
        redirect_to new_user_session_path
      end
    end

    # Post /users/update_password
    def update_password
      @form = Users::Sessions::ResetPasswordForm.new(Reform::OpenForm.new)
      if @form.validate(params[:session])
        @form.save
        @form.user.update!(account_deletion_notification_sent_at: nil)
        sign_in @form.user
        render json: { error: nil, path: after_sign_in_path_for(current_user) }
      else
        render json: { error: @form.errors.full_messages.join(", "), path: nil }
      end
    end

    # POST /user/sign_in
    def create
      @form =
        if params[:password_sign_in]
          Users::Sessions::SignInWithPasswordForm.new(Reform::OpenForm.new)
        elsif params[:email_link]
          Users::Sessions::SignInWithEmailForm.new(Reform::OpenForm.new)
        end

      @form&.current_school = current_school

      recaptcha_success =
        recaptcha_success?(@form, action: "user_password_login")

      unless recaptcha_success
        redirect_to sign_in_with_email_path(visible_recaptcha: 1)
        return
      end

      if params[:password_sign_in]
        process_password_login
      elsif params[:email_link]
        process_link_login
      else
        redirect_to sign_in_with_email_path
      end
    end

    # GET /users/sign_in_with_email
    def sign_in_with_email
      if current_user.present?
        flash[:notice] = t(".already_signed")
        redirect_to after_sign_in_path_for(current_user)
        return
      end

      @show_checkbox_recaptcha = params[:visible_recaptcha].present?
    end

    # GET /users/request_password_reset
    def request_password_reset
      if current_user.present?
        redirect_to edit_user_path
        return
      end

      @show_checkbox_recaptcha = params[:visible_recaptcha].present?
    end

    # GET /users/auth_callback?encrypted_token=xxx
    def auth_callback
      begin
        crypt = EncryptorService.new

        data =
          crypt.decrypt(
            Base64.urlsafe_decode64(params[:encrypted_token].presence || "")
          )
        session_id = Base64.urlsafe_decode64(data[:session_id])

        # Abort if the session is invalid
        if session_id.to_s != session.id.private_id.to_s
          flash[:error] = t(".invalid_session")
          redirect_to new_user_session_path
          return
        end

        # Link discord account to user if the request has discord data
        if data[:login_token].blank? && current_user.present? &&
             data[:auth_hash]&.dig(:discord)&.dig(:uid).present?
          if current_school.users.exists?(
               discord_user_id: data[:auth_hash][:discord][:uid]
             )
            flash[:error] = t(".discord_already_linked")
            redirect_to edit_user_path
            return
          end

          onboard_user =
            Discord::AddMemberService.new(current_user).execute(
              data[:auth_hash][:discord][:uid],
              data[:auth_hash][:discord][:tag],
              data[:auth_hash][:discord][:access_token]
            )

          if onboard_user
            flash[:success] = t(".success")
          else
            flash[:error] = t(".discord_link_error")
          end

          redirect_to edit_user_path
          return
        end

        user =
          Users::AuthenticationService.new(
            current_school,
            data[:login_token]
          ).authenticate

        if user.present?
          sign_in user
          remember_me(user)
          redirect_to after_sign_in_path_for(user)
        else
          flash[:error] = t(".error")
          redirect_to new_user_session_path
        end
      rescue ActiveSupport::MessageEncryptor::InvalidMessage
        flash[:error] = t(".error")
        redirect_to new_user_session_path
      end
    end

    private

    def process_password_login
      if @form.validate(params)
        sign_in @form.user
        @form.user.update!(account_deletion_notification_sent_at: nil)
        remember_me(@form.user) unless @form.shared_device?
        redirect_to after_sign_in_path_for(current_user)
      else
        flash[:error] = @form.errors.full_messages.join(", ")
        redirect_to sign_in_with_email_path
      end
    end

    def process_link_login
      if @form.validate(params.merge(referrer: stored_location_for(:user)))
        @form.save
        render "email_sent", locals: { kind: :magic_link }
      else
        flash[:error] = @form.errors.full_messages.join(", ")
        redirect_to sign_in_with_email_path
      end
    end

    def must_have_current_school
      raise_not_found if current_school.blank?
    end
  end
end
