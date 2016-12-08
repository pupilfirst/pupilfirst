module Targets
  class StatsService
    def initialize(target)
      @target = target
    end

    # Returns array of Startups or Founders who have completed the target
    def completed_assignees
      @target.founder? ? completed_founders : completed_startups
    end

    # Returns count of Startups or Founders who have completed the target
    def completed_count
      @target.founder? ? completed_founders.count : completed_startups.count
    end

    # Returns array of Startups or Founders who have the target unavailable
    def unavailable_assignees
      @target.founder? ? unavailable_founders : unavailable_startups
    end

    # Returns count of Startups or Founders who have the target unavailable
    def unavailable_count
      @target.founder? ? unavailable_founders.count : unavailable_startups.count
    end

    # Returns array of Startups or Founders who have the target pending
    def pending_assignees
      @target.founder? ? pending_founders : pending_startups
    end

    # Returns count of Startups or Founders who have the target pending
    def pending_count
      @target.founder? ? pending_founders.count : pending_startups.count
    end

    private

    def events_of_completion
      @completed_events ||= TimelineEvent.where(target: @target).verified_or_needs_improvement
    end

    def completed_founders
      @completed_founders ||= Founder.where(id: events_of_completion.select(:founder_id).distinct)
    end

    def completed_startups
      @completed_startups ||= Startup.where(id: events_of_completion.select(:startup_id).distinct)
    end

    def unavailable_founders
      @target.batch.founders.select { |founder| @target.status(founder) == Targets::StatusService::STATUS_UNAVAILABLE }
    end

    def unavailable_startups
      @target.batch.startups.select { |startup| @target.status(startup.admin) == Targets::StatusService::STATUS_UNAVAILABLE }
    end

    def pending_founders
      @target.batch.founders - completed_founders - unavailable_founders
    end

    def pending_startups
      @target.batch.startups - completed_startups - unavailable_startups
    end
  end
end
