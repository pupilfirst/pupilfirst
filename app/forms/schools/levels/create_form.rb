module Schools
  module Levels
    class CreateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :number, validates: { format: { with: /\A\d+\z/, message: "Not a valid number" } }
      property :course_id, validates: { presence: true }
      property :unlock_on

      validate :course_exists
      validate :level_number_exists

      def save
        level = Level.new(
          course: course,
          name: name,
          number: number
        )
        level.unlock_on = unlock_on if unlock_on.present?
        level.save
        level
      end

      private

      def course_exists
        errors[:base] << 'Invalid course_id' if course.blank?
      end

      def course
        @course ||= Course.find_by(id: course_id)
      end

      def level_number_exists
        return if course.levels.blank?

        errors[:base] << 'Level number exists' if course.levels.where(number: number).present?
      end
    end
  end
end
