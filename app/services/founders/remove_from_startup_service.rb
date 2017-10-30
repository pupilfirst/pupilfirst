module Founders
  class RemoveFromStartupService
    NoOtherFoundersInStartupException = Class.new(StandardError)
    def initialize(founder)
      @founder = founder
      @startup = founder.startup
    end

    def execute
      assign_new_team_lead if @founder.team_lead?
      remove_from_startup
    end

    private

    def assign_new_team_lead
      team_lead_candidate = @startup.founders.where.not(id: @founder.id).first
      raise NoOtherFoundersInStartupException if team_lead_candidate.blank?
      @startup.update!(team_lead: team_lead_candidate)
    end

    def remove_from_startup
      raise NoOtherFoundersInStartupException if @startup.founders.count == 1
      @founder.update!(startup_id: nil)
    end
  end
end
