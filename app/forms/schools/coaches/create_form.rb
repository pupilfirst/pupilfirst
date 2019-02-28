module Schools
  module Coaches
    class CreateForm < Reform::Form
      property :email, validates: { email: true }, virtual: true
      property :name, validates: { presence: true, length: { maximum: 250 } }

      def save(course)
        Faculty.transaction do
          faculty = ::FacultyModule::CreateService.new(email, name).create
          ::Courses::AssignReviewerService.new(course).assign(faculty)
        end
      end
    end
  end
end
