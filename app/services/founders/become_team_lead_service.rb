module Founders
  class BecomeTeamLeadService
    AlreadyTeamLeadException = Class.new(StandardError)
    NotMemberOfStartupException = Class.new(StandardError)

    def initialize(founder)
      @founder = founder
    end

    def execute
      raise AlreadyTeamLeadException if startup&.team_lead == @founder
      raise NotMemberOfStartupException if startup.blank? || !@founder.in?(startup.founders)

      Founder.transaction do
        startup.update!(team_lead: @founder)
      end
    end

    private

    def startup
      @startup ||= @founder.startup
    end
  end
end
