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
        expired: expired_assignees.count,
        unavailable: unavailable_assignees.count
      }
    end

    def completed_assignees
      @completed_assignees ||= event_owners(linked_events.verified)
    end

    def completed_events_with_assignees
      join_assignees(latest_linked_events.verified)
    end

    def submitted_assignees
      @submitted_assignees ||= event_owners(linked_events.pending)
    end

    def submitted_events_with_assignees
      join_assignees(latest_linked_events.pending)
    end

    def needs_improvement_assignees
      @needs_improvement_assignees ||= event_owners(linked_events.needs_improvement)
    end

    def needs_improvement_events_with_assignees
      join_assignees(latest_linked_events.needs_improvement)
    end

    def not_accepted_assignees
      @not_accepted_assignees ||= event_owners(linked_events.not_accepted)
    end

    def not_accepted_events_with_assignees
      join_assignees(latest_linked_events.not_accepted)
    end

    def pending_assignees
      assignees_in_batch.select { |assignee| status_for(assignee) == Targets::StatusService::STATUS_PENDING }
    end

    def expired_assignees
      assignees_in_batch.select { |assignee| status_for(assignee) == Targets::StatusService::STATUS_EXPIRED }
    end

    def unavailable_assignees
      assignees_in_batch.select { |assignee| status_for(assignee) == Targets::StatusService::STATUS_UNAVAILABLE }
    end

    private

    def linked_events
      TimelineEvent.where(target: @target)
    end

    def latest_linked_events
      if @target.founder_role?
        linked_events.select('DISTINCT ON (founder_id) *').order('founder_id, event_on DESC')
      else
        linked_events.select('DISTINCT ON (startup_id) *').order('timeline_events.startup_id, event_on DESC')
      end
    end

    def join_assignees(events)
      @target.founder_role? ? events.joins(:founder) : events.joins(:startup)
    end

    def event_owners(events)
      @target.founder_role? ? founders(events) : startups(events)
    end

    def founders(events)
      Founder.where(id: events.select(:founder_id).distinct)
    end

    def startups(events)
      Startup.where(id: events.select(:startup_id).distinct)
    end

    def assignees_in_batch
      @target.founder_role? ? founders_in_batch : startups_in_batch
    end

    def founders_in_batch
      @target.batch.founders
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
