module Targets
  class StatusService
    STATUS_PENDING = :pending
    STATUS_COMPLETE = :complete
    STATUS_UNAVAILABLE = :unavailable

    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def status
      return STATUS_COMPLETE if complete?
      return STATUS_PENDING if pending_prerequisites.empty?
      STATUS_UNAVAILABLE
    end

    def completed_prerequisites
      Target.where(id: completed_prerequisites_ids)
    end

    def pending_prerequisites
      @target.prerequisite_targets.where.not(id: completed_prerequisites_ids)
    end

    private

    def complete?
      owner_events.where(target: @target).present?
    end

    def owner_events
      owner.timeline_events.verified_or_needs_improvement
    end

    def owner
      @target.founder? ? @founder : @founder.startup
    end

    def completed_prerequisites_ids
      @completed_prerequisites_ids ||= begin
        owner_events.where(target: @target.prerequisite_targets.pluck(:id)).select(:target_id).distinct
      end
    end
  end
end
