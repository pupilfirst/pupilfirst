module Users
  module Sessions
    class SendLoginEmailPresenter < ApplicationPresenter
      def school_name
        @school_name ||= current_school&.name || 'Pupilfirst'
      end
    end
  end
end
