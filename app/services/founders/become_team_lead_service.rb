module Founders
  class BecomeTeamLeadService
    AlreadyTeamLeadException = Class.new(StandardError)
    NotMemberOfStartupException = Class.new(StandardError)

    def initialize(founder)
      @founder = founder
    end

    def execute
      raise AlreadyTeamLeadException if @founder.team_lead?
      raise NotMemberOfStartupException if startup.blank? || !@founder.in?(startup.founders)

      startup.update!(team_lead: @founder)
    end

    private

    def startup
      @startup ||= @founder.startup
    end
  end
end
