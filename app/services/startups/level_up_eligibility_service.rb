module Startups
  # This service should be used to check whether a startup is eligible to _level up_ - to move up a level in the main
  # program - it does this by checking whether all milestone targets have been completed.
  class LevelUpEligibilityService
    def initialize(startup, founder)
      @startup = startup
      @founder = founder
      @cofounders_pending = false
    end

    ELIGIBILITY_ELIGIBLE = -'eligible'
    ELIGIBILITY_NOT_ELIGIBLE = -'not_eligible'
    ELIGIBILITY_COFOUNDERS_PENDING = -'cofounders_pending'

    def eligible?
      eligibility == ELIGIBILITY_ELIGIBLE
    end

    def eligibility
      @eligibility ||= begin
        all_targets_complete = milestone_targets.all? do |target|
          target_completed?(target)
        end

        if all_targets_complete
          return ELIGIBILITY_COFOUNDERS_PENDING if @cofounders_pending
          return ELIGIBILITY_ELIGIBLE
        end

        ELIGIBILITY_NOT_ELIGIBLE
      end
    end

    private

    def milestone_targets
      @startup.level.target_groups.find_by(milestone: true).targets.where(archived: false)
    end

    def target_completed?(target)
      if target.founder_role?
        completed_founders = @startup.founders.all.select do |startup_founder|
          target.status(startup_founder) == Targets::StatusService::STATUS_COMPLETE
        end

        if @founder.in?(completed_founders)
          # Mark that some co-founders haven't yet completed target if applicable.
          @cofounders_pending = completed_founders.count != @startup.founders.count

          # Founder has completed this target.
          true
        else
          false
        end
      else
        Targets::StatusService.new(target, @founder).status == Targets::StatusService::STATUS_COMPLETE
      end
    end
  end
end
