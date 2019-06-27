module Levels
  class DeleteService
    def initialize(level)
      @level = level
    end

    def execute
      raise "Level #{@level.number} cannot be deleted" if @level.number < 2

      Level.transaction do
        # Link startups and target groups to previous level.
        @level.startups.each do |startup|
          startup.level = previous_level
          startup.save!
        end

        @level.target_groups.each do |target_group|
          target_group.level = previous_level
          target_group.save!
        end

        # Remove the level.
        @level.reload.destroy!

        # Re-number higher levels.
        higher_levels.each do |level|
          level.update!(number: (level.number - 1))
        end
      end
    end

    def previous_level
      @previous_level ||= begin
        l = course.levels.find_by(number: (@level.number - 1))

        raise "Abort! Could not find the level immediately before Level##{@level.id}" if l.blank?

        l
      end
    end

    def higher_levels
      course.levels.where('number > ?', @level.number)
    end

    def course
      @course ||= @level.course
    end
  end
end
