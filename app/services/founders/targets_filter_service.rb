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
      submitted_targets.merge(TimelineEvent.needs_improvement)
    end

    def not_accepted_targets
      submitted_targets.merge(TimelineEvent.not_accepted)
    end

    def due_date_service
      @due_date_service ||= Targets::DueDateService.new(@founder.startup.batch).tap(&:prepare)
    end

    def sorted(targets)
      targets.sort_by { |target| due_date_service.due_date(target) }
    end
  end
end
