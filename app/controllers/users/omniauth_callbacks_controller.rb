module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    skip_before_action :verify_authenticity_token, only: [:developer]

    # GET /users/auth/:action/callback
    def oauth_callback
      email = email_from_auth_hash

      if email.blank?
        flash[:error] = email_blank_flash
        redirect_to new_user_session_path
        return
      end

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

    # This method validates the format of auth_hash. This ensures that we capture any 'oddities' as crashes, instead of
    # letting issues get buried (we used to show a useless 404).
    def email_from_auth_hash
      raise "Auth hash is blank: #{auth_hash.inspect}" if auth_hash.blank?
      auth_hash.dig(:info, :email)
    end

    def provider_name
      params[:action].split('_').first.capitalize
    end

    def email_blank_flash
      message = "We're sorry, but we did not receive your email address from #{provider_name}. "

      message += case provider_name
        when 'Github'
          'Please <a href="https://github.com/settings/profile" target="_blank">add a public email address to your Github profile</a> and try again.'
        when 'Facebook'
          'Please <a href="https://www.facebook.com/settings?tab=applications" target="_blank">remove SV.CO from your authorized apps list</a> and try signing in again.'
        else
          'Please sign in using another method.'
      end

      message.html_safe
    end
  end
end
