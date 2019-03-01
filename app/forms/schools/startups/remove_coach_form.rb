module Schools
  module Startups
    class RemoveCoachForm < Reform::Form
      property :coach_id, validates: { presence: true }
      property :startup_id, validates: { presence: true }

      validate :coach_and_startup_exists

      def save
        ::Startups::UnassignReviewerService.new(startup).unassign(coach)
      end

      private

      def coach
        @coach ||= Faculty.find_by(id: coach_id)
      end

      def startup
        @startup ||= Startup.find_by(id: startup_id)
      end

      def coach_and_startup_exists
        errors[:base] << 'Invalid coach id' if coach.blank?
        errors[:base] << 'Invalid startup id' if startup.blank?
      end
    end
  end
end
