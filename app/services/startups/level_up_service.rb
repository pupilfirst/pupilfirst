module Startups
  class LevelUpService
    def initialize(startup)
      @startup = startup
    end

    def execute
      @startup.update!(level: next_level)
    end

    private

    def next_level
      Level.find_by(number: @startup.level.number + 1)
    end
  end
end
