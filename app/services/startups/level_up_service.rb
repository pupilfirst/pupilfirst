module Startups
  # This service should be used to upgrade a startup to the next level.
  class LevelUpService
    def initialize(startup)
      @startup = startup
    end

    def execute
      raise 'Maximum level reached - cannot level up.' unless next_level.present?

      level_up
    end

    private

    def level_up
      @startup.update!(level: next_level)
    end

    def course
      @course ||= @startup.level.course
    end

    def next_level
      @next_level ||= course.levels.find_by(number: @startup.level.number + 1)
    end
  end
end
