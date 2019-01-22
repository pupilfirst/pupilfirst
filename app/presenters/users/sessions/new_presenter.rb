module Users
  module Sessions
    class NewPresenter < ApplicationPresenter
      def initialize(view_context, sign_in_error)
        @sign_in_error = sign_in_error
        super(view_context)
      end

      def school_name
        @school_name ||= view.current_school&.name || 'PupilFirst'
      end

      def oauth_url(provider)
        view.oauth_url(provider: provider, fqdn: view.current_host, host: oauth_host)
      end

      def hidden_sign_in_class(type, link: false)
        add_class = type == 'federated' ? link : !link
        add_class = !add_class if @sign_in_error
        add_class ? 'd-none' : ''
      end

      private

      def oauth_host
        @oauth_host ||= "www.pupilfirst.#{Rails.env.production? ? 'com' : 'localhost'}"
      end
    end
  end
end
