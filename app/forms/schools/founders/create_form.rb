module Schools
  module Founders
    class CreateForm < Reform::Form
      property :course_id, validates: { presence: true }

      collection :students, populate_if_empty: OpenStruct, virtual: true, default: [] do
        property :name, validates: { presence: true, length: { maximum: 250 } }
        property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: EmailValidator::REGULAR_EXPRESSION, message: "doesn't look like an email" } }
        property :title
        property :affiliation
        property :tags
        property :team_name, validates: { length: { maximum: 50 } }
      end

      validate :students_must_have_unique_email

      def students_must_have_unique_email
        return if students.map(&:email).uniq.count == students.count

        errors[:base] << 'email addresses must be unique'
      end

      def save
        ::Courses::AddStudentsService.new(course).add(students)
      end

      private

      def course
        @course ||= Course.find(course_id)
      end
    end
  end
end
