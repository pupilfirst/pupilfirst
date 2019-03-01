module Schools
  module Startups
    class AddCoachForm < Reform::Form
      property :id
      property :email, virtual: true
      property :name
      property :team_id, virtual: true, validates: { presence: true }

      validates :email, email: true, unless: :existing_faculty
      validates :name, :email, presence: true, unless: :existing_faculty
      validate :team_exists

      def save
        faculty = existing_faculty || ::FacultyModule::CreateService.new(email, name).create
        ::Startups::AssignReviewerService.new(startup).assign(faculty)
      end

      private

      def existing_faculty
        @existing_faculty ||= Faculty.find_by(id: id)
      end

      def startup
        @startup ||= Startup.find_by(id: team_id)
      end

      def team_exists
        return if startup.present?

        errors[:base] << 'Invalid team_id'
      end
    end
  end
end
