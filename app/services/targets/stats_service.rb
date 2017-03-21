module Targets
  class StatsService
    def initialize(target)
      @target = target
    end

    def counts
      {
        completed: completed_assignees.count,
        submitted: submitted_assignees.count,
        needs_improvement: needs_improvement_assignees.count,
        not_accepted: not_accepted_assignees.count,
        pending: pending_assignees.count,
        unavailable: unavailable_assignees.count
      }
    end

    def completed_assignees
      @completed_assignees ||= event_owners(latest_linked_events.select(&:verified?))
    end

    def submitted_assignees
      @submitted_assignees ||= event_owners(latest_linked_events.select(&:pending?))
    end

    def needs_improvement_assignees
      @needs_improvement_assignees ||= event_owners(latest_linked_events.select(&:needs_improvement?))
    end

    def not_accepted_assignees
      @not_accepted_assignees ||= event_owners(latest_linked_events.select(&:not_accepted?))
    end

    def pending_assignees
      assignees_in_batch.select { |assignee| status_for(assignee) == Targets::StatusService::STATUS_PENDING }
    end

    def unavailable_assignees
      assignees_in_batch.select { |assignee| status_for(assignee) == Targets::StatusService::STATUS_UNAVAILABLE }
    end

    private

    def latest_linked_events
      linked_events = TimelineEvent.where(target: @target)

      # Return only the latest per assignee.
      if @target.founder_role?
        linked_events.select('DISTINCT ON (founder_id) *').order('founder_id, event_on DESC').to_a
      else
        linked_events.select('DISTINCT ON (startup_id) *').order('startup_id, event_on DESC').to_a
      end
    end

    def event_owners(events)
      @target.founder_role? ? founders(events) : startups(events)
    end

    def founders(events)
      Founder.where(id: events.map(&:founder_id)).not_exited
    end

    def startups(events)
      Startup.where(id: events.map(&:startup_id))
    end

    def assignees_in_batch
      @target.founder_role? ? founders_in_batch : startups_in_batch
    end

    def founders_in_batch
      @target.batch.founders.not_exited
    end

    def startups_in_batch
      @target.batch.startups
    end

    def status_for(assignee)
      @target.status(representative(assignee))
    end

    def representative(assignee)
      assignee.is_a?(Founder) ? assignee : assignee.admin
    end
  end
end
