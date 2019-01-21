module Users
  module Sessions
    class NewPresenter < ApplicationPresenter
      def sign_in_with_email_heading
        "Sign in with your #{school_name} ID"
      end

      def federated_sign_in_heading
        "Sign in to #{school_name}"
      end

      private

      def school_name
        @school_name ||= view.current_school&.name || 'PupilFirst'
      end
    end
  end
end
