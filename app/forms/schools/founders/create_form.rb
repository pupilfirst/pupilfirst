module Schools
  module Founders
    class CreateForm < Reform::Form
      property :course_id, validates: { presence: true }
      collection :students, populate_if_empty: OpenStruct, virtual: true, default: [] do
        property :name, validates: { presence: true, length: { maximum: 250 } }
        property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: EmailValidator::REGULAR_EXPRESSION, message: "doesn't look like an email" } }
      end

      validate :student_does_not_exist

      def save
        ::Courses::AddStudentsService.new(course).add(students)
      end

      private

      def course
        @course ||= Course.find(course_id)
      end

      def student_does_not_exist
        existing_student_emails = course.founders.includes(:user).map(&:email)

        if students.map(&:email).any? { |email| email.in?(existing_student_emails) }
          errors[:base] << 'Student(s) with given email(s) already exist in this course!'
        end
      end
    end
  end
end
