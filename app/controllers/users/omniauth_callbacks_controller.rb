module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    skip_before_action :verify_authenticity_token, only: [:developer]

    # GET /users/auth/:provider/callback
    def oauth_callback
      raise_not_found if auth_hash.blank?
      email = auth_hash.dig(:info, :email)
      raise_not_found if email.blank?
      user = User.with_email(email).first

      if user.present?
        sign_in user
        remember_me user
        redirect_to after_sign_in_path_for(user)
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

    # Omniauth related
    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
