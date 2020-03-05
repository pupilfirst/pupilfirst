module Users
  module Sessions
    class ResetPassword < ApplicationPresenter
      def initialize(view_context, token)
        @token = token
        super(view_context)
      end

      def page_title
        "Reset Password | #{school_name}"
      end

      private

      def props
        {
          authenticity_token: view.form_authenticity_token,
          token: @token
        }
      end

      def school_name
        @school_name ||= current_school&.name || 'Pupilfirst'
      end
    end
  end
end
