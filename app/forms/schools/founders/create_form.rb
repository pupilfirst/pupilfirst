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
