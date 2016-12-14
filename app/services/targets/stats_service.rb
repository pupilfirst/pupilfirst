module Targets
  class StatsService
    def initialize(target)
      @target = target
    end

    # Returns count of Startups or Founders who have the target unavailable
    def unavailable_count
      @target.founder_role? ? unavailable_founders.count : unavailable_startups.count
    end

    # Returns count of Startups or Founders who have the target pending
    def pending_count
      @target.founder_role? ? pending_founders.count : pending_startups.count
    end

    # Returns count of Startups or Founders who have the target expired
    def expired_count
      @target.founder_role? ? expired_founders.count : expired_startups.count
    end

    # Returns count of Startups or Founders who have completed the target
    def completed_count
      @target.founder_role? ? completed_founders.count : completed_startups.count
    end

    # Returns count of Startups or Founders who have submitted the target
    def submitted_count
      @target.founder_role? ? submitted_founders.count : submitted_startups.count
    end

    # Returns count of Startups or Founders whose submission needs improvement
    def needs_improvement_count
      @target.founder_role? ? needs_improvement_founders.count : needs_improvement_startups.count
    end

    def not_accepted_count
      @target.founder_role? ? not_accepted_founders.count : not_accepted_startups.count
    end

    private

    def linked_events
      TimelineEvent.where(target: @target)
    end

    def completed_founders
      @completed_founders ||= Founder.where(id: linked_events.verified.select(:founder_id).distinct)
    end

    def completed_startups
      @completed_startups ||= Startup.where(id: linked_events.verified.select(:startup_id).distinct)
    end

    def submitted_founders
      @submitted_founders ||= Founder.where(id: linked_events.pending.select(:founder_id).distinct)
    end

    def submitted_startups
      @submitted_startups ||= Startup.where(id: linked_events.pending.select(:startup_id).distinct)
    end

    def needs_improvement_founders
      @needs_improvement_founders ||= Founder.where(id: linked_events.needs_improvement.select(:founder_id).distinct)
    end

    def needs_improvement_startups
      @needs_improvement_startups ||= Startup.where(id: linked_events.needs_improvement.select(:startup_id).distinct)
    end

    def not_accepted_founders
      @not_accepted_founders ||= Founder.where(id: linked_events.not_accepted.select(:founder_id).distinct)
    end

    def not_accepted_startups
      @not_accepted_startups ||= Startup.where(id: linked_events.not_accepted.select(:startup_id).distinct)
    end

    def unavailable_founders
      @target.batch.founders.select { |founder| @target.status(founder) == Targets::StatusService::STATUS_UNAVAILABLE }
    end

    def unavailable_startups
      @target.batch.startups.select { |startup| @target.status(startup.admin) == Targets::StatusService::STATUS_UNAVAILABLE }
    end

    def pending_founders
      @target.batch.founders.select { |founder| @target.status(founder) == Targets::StatusService::STATUS_PENDING }
    end

    def pending_startups
      @target.batch.startups.select { |startup| @target.status(startup.admin) == Targets::StatusService::STATUS_PENDING }
    end

    def expired_founders
      @target.batch.founders.select { |founder| @target.status(founder) == Targets::StatusService::STATUS_EXPIRED }
    end

    def expired_startups
      @target.batch.startups.select { |startup| @target.status(startup.admin) == Targets::StatusService::STATUS_EXPIRED }
    end
  end
end
