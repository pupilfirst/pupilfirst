module Users
  module Sessions
    class SendLoginEmailPresenter < ApplicationPresenter
      def school_name
        @school_name ||= current_school&.name || 'PupilFirst'
      end
    end
  end
end
