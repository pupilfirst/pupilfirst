module Schools
  module Founders
    class CreateForm < Reform::Form
      property :course_id, validates: { presence: true }

      collection :students, populate_if_empty: OpenStruct, virtual: true, default: [] do
        property :name, validates: { presence: true, length: { maximum: 250 } }
        property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: EmailValidator::REGULAR_EXPRESSION, message: "doesn't look like an email" } }
        property :tags
      end

      def save
        ::Courses::AddStudentsService.new(course).add(new_students)
      end

      private

      def new_students
        requested_emails = students.map(&:email)
        enrolled_student_emails = course.founders.joins(:user).where(users: { email: requested_emails }).pluck(:email)

        students.reject do |student|
          student.email.in?(enrolled_student_emails)
        end
      end

      def course
        @course ||= Course.find(course_id)
      end
    end
  end
end
