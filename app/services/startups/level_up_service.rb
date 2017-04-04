module Startups
  # This service should be used to upgrade a startup to the next level.
  class LevelUpService
    def initialize(startup)
      @startup = startup
    end

    def execute
      if next_level.present?
        if next_level.number == 1
          @startup.update!(level: next_level, program_started_at: Time.zone.now)
        else
          @startup.update!(level: next_level)
        end
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
