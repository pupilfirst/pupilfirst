module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    skip_before_action :verify_authenticity_token, only: [:developer]

    # GET /users/auth/:provider/callback
    def oauth_callback
      raise_not_found if auth_hash.blank?
      email = auth_hash.dig(:info, :email)
      raise_not_found if email.blank?
      user = User.with_email(email)

      if user.present?
        sign_in user
        remember_me user
        Users::ConfirmationService.new(user).execute
        redirect_to origin || after_sign_in_path_for(user)
      else
        flash[:notice] = "Your email address: #{email} is not registered at SV.CO"
        redirect_to new_user_session_path
      end
    end

    alias google_oauth2 oauth_callback
    alias facebook oauth_callback
    alias github oauth_callback
    alias developer oauth_callback

    private

    # This is a hack to resolve the issue of flashing message 'You are already signed in' when signing in using OAuth.
    # For an unknown reason, the request env variable omniauth.origin defaults to the sign in path when no origin is
    # supplied to the omniauth provider login path. This method detects and removes that default.
    def origin
      supplied_origin = request.env['omniauth.origin']
      supplied_origin =~ %r{users/sign_in} ? nil : supplied_origin
    end

    # Omniauth returns authentication details in the 'omniauth.auth' request environment variable after the provider
    # redirects back to our website. The format for this return value is documented by Omniauth.
    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
