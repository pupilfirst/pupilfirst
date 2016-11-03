module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    # GET /users/auth/:provider/callback
    def oauth_callback
      raise_not_found if auth_hash.blank?
      @user = Users::AuthenticationService.user_from_oauth(auth_hash)
      sign_in @user
      remember_me @user
      console
      redirect_to after_sign_in_path_for(@user)
    end

    alias google_oauth2 oauth_callback
    alias facebook oauth_callback
    alias github oauth_callback

    private

    # Omniauth related
    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
