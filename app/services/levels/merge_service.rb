module Levels
  class MergeService
    def initialize(level)
      @level = level
    end

    def merge_into(other_level)
      raise 'Cannot merge into level zero' if other_level.number.zero?

      Level.transaction do
        # Link startups and target groups to supplied level.
        @level.startups.update_all(level_id: other_level.id) # rubocop:disable Rails/SkipsModelValidations
        @level.target_groups.update_all(level_id: other_level.id) # rubocop:disable Rails/SkipsModelValidations

        # Remove the level.
        @level.reload.destroy!

        # Re-number all remaining levels.
        course.levels.order(number: :asc).each.with_index(minimum_level_number) do |level, index|
          level.update!(number: index) if level.number != index
        end
      end

      other_level
    end

    def minimum_level_number
      course.levels.exists?(number: 0) ? 0 : 1
    end

    def course
      @course ||= @level.course
    end
  end
end
