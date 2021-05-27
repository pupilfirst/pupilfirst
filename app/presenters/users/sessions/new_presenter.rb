module Users
  module Sessions
    class NewPresenter < ApplicationPresenter
      def page_title
        "#{I18n.t('sessions.new.page_title')} | #{school_name}"
      end

      def allow_email_sign_in?
        allow_email = ENV.fetch('ALLOW_EMAIL_SIGN_IN') { false }
        ActiveModel::Type::Boolean.new.cast(allow_email)
      end

      def school_name
        @school_name ||= current_school.name
      end

      def oauth_host
        return @oauth_host if @oauth_host

        @oauth_host = Rails.application.secrets.sso_domain
      end

      def providers
        default_providers = %i[google facebook github keycloak_openid]

        if Rails.env.development?
          [:developer] + default_providers
        else
          default_providers
        end
      end

      def button_classes(provider)
        default_classes =
          'flex justify-center items-center px-3 py-2 leading-snug border border-transparent rounded-lg cursor-pointer font-semibold mt-4 w-full '

        default_classes +
          case (provider)
          when :facebook
            'federated-sigin-in__facebook-btn hover:bg-blue-800 text-white'
          when :github
            'federated-sigin-in__github-btn hover:bg-black text-white'
          when :google
            'federated-sigin-in__google-btn hover:bg-red-600 text-white'
          when :developer
            'bg-green-100 border-green-400 text-green-800 hover:bg-green-200'
          when :keycloak_openid
            'federated-sigin-in__github-btn hover:bg-siliconBlue-900 text-white'
          else
            raise_unexpected_provider(provider)
          end
      end

      def federated_login_url(provider)
        provider_key =
          case (provider)
          when :google
            'google'
          when :facebook
            'facebook'
          when :github
            'github'
          when :developer
            'developer'
          when :keycloak_openid
            'keycloakopenid'
          else
            raise_unexpected_provider(provider)
          end

        "//#{oauth_host}/oauth/#{provider_key}?fqdn=#{view.current_host}"
      end

      def icon_classes(provider)
        case provider
        when :google
          'fab fa-google'
        when :facebook
          'fab fa-facebook-f mr-1'
        when :github
          'fab fa-github'
        when :developer
          'fas fa-laptop-code'
        when :keycloak_openid
          'fas fa-key'
        else
          raise_unexpected_provider(provider)
        end
      end

      def button_text(provider)
        key =
          case provider
          when :google
            'continue_with_google'
          when :facebook
            'continue_with_facebook'
          when :github
            'continue_with_github'
          when :developer
            'continue_as_developer'
          when :keycloak_openid
            'continue_with_keycloak'
          else
            raise_unexpected_provider(provider)
          end

        I18n.t("sessions.new.#{key}")
      end

      def raise_unexpected_provider(provider)
        raise "Was asked to handle unexpected provider: #{provider}"
      end
    end
  end
end
