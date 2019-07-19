module Users
  module Sessions
    class NewPresenter < ApplicationPresenter
      def initialize(view_context)
        super(view_context)
      end

      def page_title
        "Sign In | #{school_name}"
      end

      private

      def props
        {
          authenticity_token: view.form_authenticity_token,
          school_name: school_name,
          fqdn: fqdn,
          oauth_host: oauth_host
        }
      end

      def school_name
        @school_name ||= current_school&.name || 'PupilFirst'
      end

      def fqdn
        if view.current_school.present?
          view.current_host
        end
      end

      def oauth_host
        @oauth_host ||= "sso.pupilfirst.#{Rails.env.production? ? 'com' : 'localhost'}"
      end
    end
  end
end
