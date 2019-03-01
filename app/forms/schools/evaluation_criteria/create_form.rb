module Schools
  module EvaluationCriteria
    class CreateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :description, validates: { presence: true, length: { maximum: 250 } }
      property :course_id, validates: { presence: true }

      validate :course_exists

      private

      def course_exists
        errors[:base] << 'Invalid course_id' if course.blank?
      end

      def course
        @course ||= Course.find_by(id: course_id)
      end
    end
  end
end
