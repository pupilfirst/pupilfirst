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

        if Rails.application.secrets.sso.dig(:discord, :key).present?
          available_providers << :discord
        end

        if Rails.application.secrets.sso.dig(:facebook, :key).present?
          available_providers << :facebook
        end

        if Rails.application.secrets.sso.dig(:github, :key).present?
          available_providers << :github
        end

        if Rails.application.secrets.sso.dig(:google, :client_id).present?
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

    def icon_svg(provider)
      case provider
      when :google
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 512 512" fill-rule="evenodd">
          <path d="M501.76 261.82a294.79 294.79 0 0 0-4.65-52.37H256v99h137.77c-5.93 32-24 59.1-51.08 77.27V450h82.74c48.4-44.57 76.33-110.2 76.33-188.16z" fill="#4285f4"/>
          <path d="M256 512c69.12 0 127.07-22.92 169.43-62l-82.74-64.23c-22.92 15.36-52.25 24.43-86.7 24.43-66.68 0-123.1-45-143.24-105.54H27.23V371A255.91 255.91 0 0 0 256 512z" fill="#34a853"/>
          <path d="M112.76,304.64a151.33,151.33,0,0,1,0-97.28V141H27.23a256.33,256.33,0,0,0,0,229.94l85.53-66.33Z" fill="#fbbc05"/>
          <path d="M256 101.82c37.6 0 71.33 12.9 97.86 38.28l73.43-73.42C383 25.37 325 0 256 0A255.91 255.91 0 0 0 27.23 141l85.53 66.33c20.13-60.48 76.56-105.5 143.24-105.5z" fill="#ea4335"/></svg>'
      when :facebook
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="#0866ff" viewBox="0 0 16 16"><path d="M16 8.049c0-4.446-3.582-8.05-8-8.05C3.58 0-.002 3.603-.002 8.05c0 4.017 2.926 7.347 6.75 7.951v-5.625h-2.03V8.05H6.75V6.275c0-2.017 1.195-3.131 3.022-3.131.876 0 1.791.157 1.791.157v1.98h-1.009c-.993 0-1.303.621-1.303 1.258v1.51h2.218l-.354 2.326H9.25V16c3.824-.604 6.75-3.934 6.75-7.951"/></svg>'
      when :github
        '<svg width="24" height="24" viewBox="0 0 98 96" xmlns="http://www.w3.org/2000/svg"><path fill="#24292f" fill-rule="evenodd" clip-rule="evenodd" d="M48.854 0C21.839 0 0 22 0 49.217c0 21.756 13.993 40.172 33.405 46.69 2.427.49 3.316-1.059 3.316-2.362 0-1.141-.08-5.052-.08-9.127-13.59 2.934-16.42-5.867-16.42-5.867-2.184-5.704-5.42-7.17-5.42-7.17-4.448-3.015.324-3.015.324-3.015 4.934.326 7.523 5.052 7.523 5.052 4.367 7.496 11.404 5.378 14.235 4.074.404-3.178 1.699-5.378 3.074-6.6-10.839-1.141-22.243-5.378-22.243-24.283 0-5.378 1.94-9.778 5.014-13.2-.485-1.222-2.184-6.275.486-13.038 0 0 4.125-1.304 13.426 5.052a46.97 46.97 0 0 1 12.214-1.63c4.125 0 8.33.571 12.213 1.63 9.302-6.356 13.427-5.052 13.427-5.052 2.67 6.763.97 11.816.485 13.038 3.155 3.422 5.015 7.822 5.015 13.2 0 18.905-11.404 23.06-22.324 24.283 1.78 1.548 3.316 4.481 3.316 9.126 0 6.6-.08 11.897-.08 13.526 0 1.304.89 2.853 3.316 2.364 19.412-6.52 33.405-24.935 33.405-46.691C97.707 22 75.788 0 48.854 0z"/></svg>'
      when :discord
        '<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 127.14 96.36"><path fill="#5865f2" d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.7,77.7,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22h0C129.24,52.84,122.09,29.11,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z"/></svg>'
      when :developer
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="#2b9b5e" viewBox="0 0 16 16"><path d="M0 3a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2zm9.5 5.5h-3a.5.5 0 0 0 0 1h3a.5.5 0 0 0 0-1m-6.354-.354a.5.5 0 1 0 .708.708l2-2a.5.5 0 0 0 0-.708l-2-2a.5.5 0 1 0-.708.708L4.793 6.5z"/></svg>'
      else
        raise "Unexpected provider: #{provider}"
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
