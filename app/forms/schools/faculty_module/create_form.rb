module Schools
  module FacultyModule
    class CreateForm < Reform::Form
      property :email, validates: { email: true }, virtual: true
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :school_id, virtual: true, validates: { presence: true }

      def save(course)
        Faculty.transaction do
          faculty = ::FacultyModule::CreateService.new(email, name, school).create
          ::Courses::AssignReviewerService.new(course).assign(faculty)
        end
      end

      private

      def school
        School.find_by(id: school_id)
      end
    end
  end
end
