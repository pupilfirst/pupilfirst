module Schools
  module Levels
    class CreateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :course_id, validates: { presence: true }
      property :unlock_at

      validate :course_exists

      def save
        level = Level.new(
          course: course,
          name: name,
          number: next_level_number,
          unlock_at: unlock_at_time
        )
        level.save
        level
      end

      private

      def unlock_at_time
        return if unlock_at.blank?

        Time.zone.parse(unlock_at)
      end

      def next_level_number
        course.levels.maximum(:number) + 1
      end

      def course_exists
        errors[:base] << 'Invalid course_id' if course.blank?
      end

      def course
        @course ||= Course.find_by(id: course_id)
      end
    end
  end
end
