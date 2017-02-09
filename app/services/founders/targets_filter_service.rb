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
      targets = case filter
        when EXPIRED
          expired_targets
        when NEEDS_IMPROVEMENT
          needs_improvement_targets
        when EXPIRES_IN_A_WEEK
          expiring_targets
        when NOT_ACCEPTED
          not_accepted_targets
        else
          raise "Unexpected filter value '#{filter}'"
      end

      sorted(targets).map(&:decorate)
    end

    private

    def batch_targets
      @founder.startup.batch.targets
    end

    def founder_targets_in_batch
      batch_targets.founder
    end

    def startup_targets_in_batch
      batch_targets.not_founder
    end

    def events_for_founder_targets
      @founder.timeline_events.where(target_id: founder_targets_in_batch)
    end

    def events_for_startup_targets
      @founder.startup.timeline_events.where(target_id: startup_targets_in_batch)
    end

    def latest_event_per_founder_target
      events_for_founder_targets.select('DISTINCT ON (target_id) *').order('target_id, event_on DESC')
    end

    def latest_event_per_startup_target
      events_for_startup_targets.select('DISTINCT ON (target_id) *').order('target_id, event_on DESC')
    end

    def needs_improvement_founder_targets
      Target.where(id: latest_event_per_founder_target.needs_improvement.pluck(:target_id))
    end

    def needs_improvement_startup_targets
      Target.where(id: latest_event_per_startup_target.needs_improvement.pluck(:target_id))
    end

    def not_accepted_founder_targets
      Target.where(id: latest_event_per_founder_target.not_accepted.pluck(:target_id))
    end

    def not_accepted_startup_targets
      Target.where(id: latest_event_per_startup_target.not_accepted.pluck(:target_id))
    end

    def submitted_founder_targets
      # Targets with founder role, where @founder has submitted an event.
      batch_targets.founder.joins(:timeline_events).where(timeline_events: { founder_id: @founder.id })
    end

    def submitted_startup_targets
      # Targets with team roles, where anyone from @founder's team has submitted an event.
      batch_targets.not_founder.joins(:timeline_events).where(timeline_events: { startup_id: @founder.startup.id })
    end

    def submitted_targets
      submitted_founder_targets.or(submitted_startup_targets)
    end

    def not_submitted_targets
      batch_targets.where.not(id: submitted_targets)
    end

    def expired_targets
      not_submitted_targets.select { |target| due_date_service.expired?(target) }
    end

    def expiring_targets
      not_submitted_targets.select { |target| due_date_service.expiring?(target) }
    end

    def needs_improvement_targets
      needs_improvement_founder_targets.or(needs_improvement_startup_targets)
    end

    def not_accepted_targets
      not_accepted_founder_targets.or(not_accepted_startup_targets)
    end

    def due_date_service
      @due_date_service ||= Targets::DueDateService.new(@founder.startup.batch).tap(&:prepare)
    end

    def sorted(targets)
      targets.sort_by { |target| due_date_service.due_date(target) }
    end
  end
end
