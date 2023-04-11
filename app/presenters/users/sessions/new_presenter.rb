module Users
  module Sessions
    class NewPresenter < ApplicationPresenter
      def page_title
        "#{I18n.t('presenters.users.sessions_new.page_title.title')} | #{school_name}"
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
        default_providers = %i[google facebook github]

        if Rails.application.secrets.sso[:discord][:key].present?
          default_providers = default_providers + [:discord]
        end

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
          when :discord
            'federated-sigin-in__discord-btn hover:bg-indigo-600 text-white'
          when :developer
            'bg-green-100 border-green-400 text-green-800 hover:bg-green-200'
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
          when :discord
            'discord'
          when :developer
            'developer'
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
          'fab fa-google'
        when :facebook
          'fab fa-facebook-f me-1'
        when :github
          'fab fa-github'
        when :discord
          'fab fa-discord'
        when :developer
          'fas fa-laptop-code'
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
          when :discord
            'continue_with_discord'
          when :developer
            'continue_as_developer'
          else
            raise_unexpected_provider(provider)
          end

        I18n.t("presenters.users.sessions_new.button_text.#{key}")
      end

      def raise_unexpected_provider(provider)
        raise "Was asked to handle unexpected provider: #{provider}"
      end
    end
  end
end
