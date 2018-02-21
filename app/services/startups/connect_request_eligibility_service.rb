module Startups
  class ConnectRequestEligibilityService
    def initialize(startup, faculty)
      @startup = startup
      @faculty = faculty
    end

    def eligible?
      return true if @faculty.level.blank?
      level = @startup.level.number
      level >= @faculty.level.number
    end
  end
end
