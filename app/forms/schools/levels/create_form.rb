module Schools
  module Levels
    class CreateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :course_id, validates: { presence: true }
      property :unlock_on

      validate :course_exists

      def save
        level = Level.new(
          course: course,
          name: name,
          number: next_level_number,
          unlock_on: unlock_on_date
        )
        level.save
        level
      end

      private

      def unlock_on_date
        return if unlock_on.blank?

        Time.zone.parse(unlock_on).to_date
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
