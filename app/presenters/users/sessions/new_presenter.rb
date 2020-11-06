module Users
  module Sessions
    class NewPresenter < ApplicationPresenter
      def page_title
        "Sign In | #{school_name}"
      end

      private

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
    end
  end
end
