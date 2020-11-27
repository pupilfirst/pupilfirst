module Users
  module Sessions
    class NewPresenter < ApplicationPresenter
      def page_title
        "Sign In | #{school_name}"
      end

      private

      def props
        allow_email = ENV.fetch('ALLOW_EMAIL_SIGN_IN') { 'false' }
        allow_email = allow_email == 'true' ? true : false
        {
          school_name: school_name,
          fqdn: view.current_host,
          oauth_host: oauth_host,
          available_oauth_providers: Devise.omniauth_providers,
          allow_email_sign_in: allow_email
        }
      end

      def school_name
        @school_name ||= current_school.name
      end

      def oauth_host
        return @oauth_host if @oauth_host

        @oauth_host = Rails.application.secrets.sso_domain
      end
    end
  end
end
