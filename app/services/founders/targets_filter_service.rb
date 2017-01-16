module Founders
  class TargetsFilterService
    def initialize(founder)
      @founder = founder
    end

    EXPIRES_IN_A_WEEK = -'expires_soon'
    EXPIRED = -'expired'
    NOT_ACCEPTED = -'not_accepted'
    NEEDS_IMPROVEMENT = -'needs_improvement'
    ALL_TARGETS = -'all_targets'

    def self.filters_for_dashboard
      [EXPIRES_IN_A_WEEK, EXPIRED, NOT_ACCEPTED, NEEDS_IMPROVEMENT, ALL_TARGETS].freeze
    end

    def self.filters_except(filter)
      filters_for_dashboard - [filter]
    end

    def filter(filter)
      targets =
        case filter
          when EXPIRED
            expired_targets
          when NEEDS_IMPROVEMENT
            needs_improvement_targets
          when EXPIRES_IN_A_WEEK
            expiring_targets
          when NOT_ACCEPTED
            not_accepted_targets
        end
      targets.map(&:decorate)
    end

    private

    def submitted_founder_targets
      # Targets with founder role, where @founder has submitted an event.
      Target.founder.joins(:timeline_events).where(timeline_events: { founder_id: @founder.id })
    end

    def submitted_startup_targets
      # Targets with team roles, where anyone from @founder's team has submitted an event.
      Target.not_founder.joins(:timeline_events).where(timeline_events: { startup_id: @founder.startup.id })
    end

    def submitted_targets
      submitted_founder_targets.or(submitted_startup_targets)
    end

    def timeline_event_missing_targets
      Target.left_joins(:timeline_events).where(timeline_events: { id: nil })
    end

    def timeline_events_mismatch_targets
      Target.left_joins(:timeline_events).where.not(timeline_events: { id: @founder.timeline_events.select(:id) })
    end

    def not_submitted_founder_targets
      # Targets with founder role, where @founder has not submitted an event.
      timeline_events_mismatch_targets.or(timeline_event_missing_targets).founder
    end

    def not_submitted_startup_targets
      # Targets with team roles, where no one from @founder's team has submitted an event.
      timeline_events_mismatch_targets.or(timeline_event_missing_targets).not_founder
    end

    def not_submitted_targets
      not_submitted_founder_targets.or(not_submitted_startup_targets).distinct
    end

    def expired_targets
      not_submitted_targets.select { |target| due_date_service.expired?(target) }
    end

    def expiring_targets
      not_submitted_targets.select { |target| due_date_service.expiring?(target) }
    end

    def needs_improvement_targets
      submitted_founder_targets.or(submitted_startup_targets).merge(TimelineEvent.needs_improvement)
    end

    def not_accepted_targets
      submitted_founder_targets.or(submitted_startup_targets).merge(TimelineEvent.not_accepted)
    end

    def due_date_service
      @due_date_service ||= Targets::DueDateService.new(@founder.startup.batch).tap(&:prepare)
    end
  end
end
