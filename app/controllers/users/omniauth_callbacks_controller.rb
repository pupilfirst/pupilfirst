module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    skip_before_action :verify_authenticity_token, only: [:developer]

    # GET /users/auth/:action/callback
    def oauth_callback
      @email = email_from_auth_hash

      if oauth_origin.present? && oauth_origin[:session_id]
        if oauth_origin[:link_data].present?
          passthru_oauth_data
        elsif @email.blank?
          redirect_to(
            oauth_error_url(
              host: oauth_origin[:fqdn],
              error: email_blank_flash
            ),
            allow_other_host: true
          )
          nil
        else
          sign_in_at_oauth_origin
        end
      else
        render "oauth_origin_missing", layout: "error"
      end
    end

    alias google_oauth2 oauth_callback
    alias facebook oauth_callback
    alias github oauth_callback
    alias discord oauth_callback
    alias developer oauth_callback

    def failure
      if oauth_origin.present?
        message = t(".denied_by", provider: oauth_origin[:provider].capitalize)

        redirect_to(
          oauth_error_url(host: oauth_origin[:fqdn], error: message),
          allow_other_host: true
        )
      else
        flash[:error] = t(".denied")
        redirect_to new_user_session_path
      end
    end

    private

    def oauth_origin
      @oauth_origin ||=
        begin
          raw_origin_data = read_cookie(:oauth_origin)

          # Parse the JSON format that origin information is stored as.
          if raw_origin_data.present?
            # Make sure the cookie isn't reused.
            cookies.delete :oauth_origin

            JSON.parse(raw_origin_data, symbolize_names: true)
          end
        end
    end

    # This method is called when the user is already signed in, and is trying to link their social account with user.
    def passthru_oauth_data
      encrypted_token =
        EncryptorService.new.encrypt(
          { auth_hash: auth_hash_data, session_id: oauth_origin[:session_id] }
        )

      token_url_options = {
        encrypted_token: Base64.urlsafe_encode64(encrypted_token),
        host: oauth_origin[:fqdn]
      }

      redirect_to(
        user_auth_callback_url(**token_url_options),
        allow_other_host: true
      )
    end

    # This method is called when the user is not signed in, and is trying to sign in using OAuth.
    def sign_in_at_oauth_origin
      if user.present?
        user.regenerate_login_token

        encrypted_token =
          EncryptorService.new.encrypt(
            {
              login_token: user.original_login_token,
              auth_hash: auth_hash_data,
              session_id: oauth_origin[:session_id]
            }
          )

        token_url_options = {
          encrypted_token: Base64.urlsafe_encode64(encrypted_token),
          host: oauth_origin[:fqdn]
        }

        redirect_to(
          user_auth_callback_url(token_url_options),
          allow_other_host: true
        )
      else
        redirect_to(
          oauth_error_url(
            host: oauth_origin[:fqdn],
            error:
              t(
                "users.omniauth_callbacks.oauth_callback.email_unregistered",
                email: @email
              )
          ),
          allow_other_host: true
        )
      end
    end

    def user
      @user ||=
        begin
          school =
            School
              .joins(:domains)
              .where(domains: { fqdn: oauth_origin[:fqdn] })
              .first
          school.users.with_email(@email).first
        end
    end

    # This method is used to pass the auth_hash data to the oauth_origin.
    def auth_hash_data
      case auth_hash[:provider]
      when "google_oauth2", "facebook", "github", "developer"
        {}
      when "discord"
        {
          discord: {
            uid: auth_hash[:uid],
            tag:
              "#{auth_hash[:extra][:raw_info][:username]}##{auth_hash[:extra][:raw_info][:discriminator]}",
            access_token: auth_hash[:credentials][:token]
          }
        }
      else
        raise_unexpected_provider(provider)
      end
    end

    # This is a hack to resolve the issue of flashing message 'You are already signed in' when signing in using OAuth.
    # For an unknown reason, the request env variable omniauth.origin defaults to the sign in path when no origin is
    # supplied to the omniauth provider login path. This method detects and removes that default.
    def origin
      supplied_origin = request.env["omniauth.origin"]
      supplied_origin.include?('users/sign_in') ? nil : supplied_origin
    end

    # Omniauth returns authentication details in the 'omniauth.auth' request environment variable after the provider
    # redirects back to our website. The format for this return value is documented by Omniauth.
    def auth_hash
      request.env["omniauth.auth"]
    end

    # This method validates the format of auth_hash. This ensures that we capture any 'oddities' as crashes, instead of
    # letting issues get buried (we used to show a useless 404).
    def email_from_auth_hash
      raise "Auth hash is blank: #{auth_hash.inspect}" if auth_hash.blank?

      auth_hash.dig(:info, :email)
    end

    def provider_name
      params[:action].split("_").first.capitalize
    end

    def email_blank_flash
      message =
        t(
          "users.omniauth_callbacks.oauth_callback.not_receive_email",
          provider_name: provider_name
        )

      message +=
        case provider_name
        when "Github"
          t("users.omniauth_callbacks.oauth_callback.add_github")
        when "Facebook"
          t("users.omniauth_callbacks.oauth_callback.add_facebook")
        else
          t("users.omniauth_callbacks.oauth_callback.add_other")
        end

      message.html_safe
    end
  end
end
