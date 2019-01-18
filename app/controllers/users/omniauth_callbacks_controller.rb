module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    skip_before_action :verify_authenticity_token, only: [:developer] # rubocop:disable Rails/LexicallyScopedActionFilter

    # GET /users/auth/:action/callback
    def oauth_callback
      @email = email_from_auth_hash

      if @email.blank?
        flash[:error] = email_blank_flash
        redirect_to new_user_session_path
        return
      end

      oauth_origin = read_cookie(:oauth_origin)

      if oauth_origin.present?
        sign_in_at_oauth_origin(oauth_origin)
      else
        sign_into_current_host
      end
    end

    alias google_oauth2 oauth_callback
    alias facebook oauth_callback
    alias github oauth_callback
    alias developer oauth_callback

    private

    def sign_in_at_oauth_origin(oauth_origin)
      # Make sure the cookie isn't reused.
      cookies.delete :oauth_origin

      # Parse the JSON format that origin information is stored as.
      origin = JSON.parse(oauth_origin, symbolize_names: true)

      if user.present?
        # Regenerate the login token.
        user.regenerate_login_token

        token_url_options = {
          token: user.login_token,
          host: origin[:fqdn]
        }

        token_url_options[:referer] = origin[:referer] if origin[:referer].present?

        # Redirect user to sign in at the origin domain with newly generated token.
        redirect_to user_token_url(token_url_options)
      else
        redirect_to oauth_unknown_url(host: origin[:fqdn], email: @email)
      end
    end

    def sign_into_current_host
      if user.present?
        sign_in user
        remember_me user
        redirect_to origin || after_sign_in_path_for(user)
      else
        flash[:notice] = "Your email address: #{@email} is not registered at SV.CO"
        redirect_to new_user_session_path
      end
    end

    def user
      @user ||= User.with_email(@email)
    end

    # This is a hack to resolve the issue of flashing message 'You are already signed in' when signing in using OAuth.
    # For an unknown reason, the request env variable omniauth.origin defaults to the sign in path when no origin is
    # supplied to the omniauth provider login path. This method detects and removes that default.
    def origin
      supplied_origin = request.env['omniauth.origin']
      %r{users/sign_in}.match?(supplied_origin) ? nil : supplied_origin
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
          'Please <a href="https://github.com/settings/profile" target="_blank" rel="noopener">add a public email address to your Github profile</a> and try again.'
        when 'Facebook'
          'Please <a href="https://www.facebook.com/settings?tab=applications" target="_blank" rel="noopener">remove SV.CO from your authorized apps list</a> and try signing in again.'
        else
          'Please sign in using another method.'
      end

      message.html_safe
    end
  end
end
