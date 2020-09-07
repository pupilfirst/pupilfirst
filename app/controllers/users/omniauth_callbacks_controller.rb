module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    skip_before_action :verify_authenticity_token, only: [:developer] # rubocop:disable Rails/LexicallyScopedActionFilter
    # GET /users/auth/:action/callback
    def oauth_callback
      @email = email_from_auth_hash

      if oauth_origin.present?
        if @email.blank?
          redirect_to oauth_error_url(host: oauth_origin[:fqdn], error: email_blank_flash)
          nil
        else
          sign_in_at_oauth_origin
        end
      else
        render 'oauth_origin_missing', layout: 'error'
      end
    end

    alias google_oauth2 oauth_callback
    alias facebook oauth_callback
    alias github oauth_callback
    alias developer oauth_callback

    def failure
      if oauth_origin.present?
        message = "Authentication was denied by #{oauth_origin[:provider].capitalize}. Please try again."
        redirect_to oauth_error_url(host: oauth_origin[:fqdn], error: message)
      else
        flash[:error] = 'Authentication was denied. Please try again.'
        redirect_to new_user_session_path
      end
    end

    private

    def oauth_origin
      @oauth_origin ||= begin
        raw_origin_data = read_cookie(:oauth_origin)

        # Parse the JSON format that origin information is stored as.
        if raw_origin_data.present?
          # Make sure the cookie isn't reused.
          cookies.delete :oauth_origin

          JSON.parse(raw_origin_data, symbolize_names: true)
        end
      end
    end

    def sign_in_at_oauth_origin
      if user.present?
        # Regenerate the login token.
        user.regenerate_login_token

        token_url_options = {
          token: user.login_token,
          host: oauth_origin[:fqdn]
        }
        # Redirect user to sign in at the origin domain with newly generated token.
        redirect_to user_token_url(token_url_options)
      else
        redirect_to oauth_error_url(host: oauth_origin[:fqdn], error: "Your email address: #{@email} is unregistered.")
      end
    end

    def user
      @user ||= begin
        school = School.joins(:domains).where(domains: { fqdn: oauth_origin[:fqdn] }).first
        school.users.with_email(@email).first
      end
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
          'Please <a href="https://www.facebook.com/settings?tab=applications" target="_blank" rel="noopener">remove \'Pupilfirst\' from your authorized apps list</a> and try signing in again.'
        else
          'Please sign in using another method.'
      end

      message.html_safe
    end
  end
end
