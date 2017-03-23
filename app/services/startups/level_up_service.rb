module Startups
  # This service should be used to upgrade a startup to the next level.
  class LevelUpService
    def initialize(startup)
      @startup = startup
    end

    def execute
      if next_level.present?
        @startup.update!(level: next_level)
      else
        raise 'Maximum level reached - cannot level up.'
      end
    end

    private

    def next_level
      @next_level ||= Level.find_by(number: @startup.level.number + 1)
    end
  end
end
