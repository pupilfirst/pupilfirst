module Startups
  class ConnectRequestEligibilityService
    def initialize(startup, faculty)
      @startup = startup
      @faculty = faculty
    end

    def eligible?
      maximum_level = @startup.maximum_level.number
      @faculty.level.present? && maximum_level >= @faculty.level.number
    end
  end
end
