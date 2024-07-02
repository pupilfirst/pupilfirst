module Users
  module Sessions
    class NewPresenter < ApplicationPresenter
      def page_title
        "#{I18n.t("presenters.users.sessions.new.page_title")} | #{school_name}"
      end

      def props
        {
          school_name: school_name,
          fqdn: view.current_host,
          oauth_host: oauth_host
        }
      end

      def school_name
        @school_name ||= current_school.name
      end

      def oauth_host
        @oauth_host ||= Rails.application.secrets.sso_domain
      end

      def providers
        available_providers = []

        if Rails.application.secrets.sso[:discord][:key].present?
          available_providers << :discord
        end

        if Rails.application.secrets.sso[:facebook][:key].present?
          available_providers << :facebook
        end

        if Rails.application.secrets.sso[:github][:key].present?
          available_providers << :github
        end

        if Rails.application.secrets.sso[:google][:key].present?
          available_providers << :google
        end

        available_providers << :developer if Rails.env.development?

        available_providers
      end

      def button_classes(provider)
        default_classes =
          "flex justify-center items-center px-3 py-2 leading-snug border border-transparent rounded-lg cursor-pointer font-semibold mt-4 w-full "

        default_classes +
          case (provider)
          when :facebook
            "federated-sigin-in__facebook-btn"
          when :github
            "federated-sigin-in__github-btn"
          when :google
            "federated-sigin-in__google-btn"
          when :discord
            "federated-sigin-in__discord-btn"
          when :developer
            "bg-primary-500 hover:bg-primary-400 text-white"
          else
            raise_unexpected_provider(provider)
          end
      end

      def federated_login_url(provider)
        provider_key =
          case (provider)
          when :google
            "google"
          when :facebook
            "facebook"
          when :github
            "github"
          when :discord
            "discord"
          when :developer
            "developer"
          else
            raise_unexpected_provider(provider)
          end

        "//#{oauth_host}/oauth/#{provider_key}?fqdn=#{view.current_host}&session_id=#{encoded_private_session_id}"
      end

      def encoded_private_session_id
        @encoded_private_session_id ||=
          Base64.urlsafe_encode64(session.id.private_id)
      end

      def session
        return view.session if view.session.loaded?

        view.session[:init] = true
        view.session
      end

      def icon_classes(provider)
        case provider
        when :google
          "fab fa-google"
        when :facebook
          "fab fa-facebook-f me-1"
        when :github
          "fab fa-github"
        when :discord
          "fab fa-discord"
        when :developer
          "fas fa-laptop-code"
        else
          raise_unexpected_provider(provider)
        end
      end

      def button_text(provider)
        key =
          case provider
          when :google
            "continue_with_google"
          when :facebook
            "continue_with_facebook"
          when :github
            "continue_with_github"
          when :discord
            "continue_with_discord"
          when :developer
            "continue_as_developer"
          else
            raise_unexpected_provider(provider)
          end

        I18n.t("presenters.users.sessions.new.button_text.#{key}")
      end

      def raise_unexpected_provider(provider)
        raise "Was asked to handle unexpected provider: #{provider}"
      end
    end
  end
end
