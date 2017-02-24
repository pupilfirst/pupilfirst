module Startups
  # This service can be used to check whether a startup is eligible to _level up_ - to move up a level in the main
  # program - it does this by checking whether all milestone targets have been completed.
  class LevelUpEligibilityService
    def initialize(startup)
      @startup = startup
    end

    def eligible?
      milestone_targets.all? do |target|
        if target.founder_role?
          startup.founders.all? do |founder|
            target_completed?(target, founder)
          end
        else
          target_completed?(target, startup.admin?)
        end
      end
    end

    private

    def milestone_targets
      @startup.level.target_groups.find_by(milestone: true).targets
    end

    def target_completed?(target, founder)
      Targets::StatusService.new(target, founder).status == Targets::StatusService::STATUS_COMPLETE
    end
  end
end
