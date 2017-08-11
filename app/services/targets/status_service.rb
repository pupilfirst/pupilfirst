module Targets
  class StatusService
    STATUS_COMPLETE = :complete
    STATUS_NEEDS_IMPROVEMENT = :needs_improvement
    STATUS_SUBMITTED = :submitted
    STATUS_PENDING = :pending
    STATUS_UNAVAILABLE = :unavailable
    STATUS_NOT_ACCEPTED = :not_accepted

    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def status
      return STATUS_UNAVAILABLE if pending_prerequisites.present?
      return status_from_event if linked_event.present?
      STATUS_PENDING
    end

    def completed_prerequisites
      Target.where(id: completed_prerequisites_ids)
    end

    def pending_prerequisites
      @target.prerequisite_targets.where.not(id: completed_prerequisites_ids)
    end

    private

    def linked_event
      @target.latest_linked_event(@founder)
    end

    def status_from_event
      return STATUS_COMPLETE if linked_event.verified?
      return STATUS_NOT_ACCEPTED if linked_event.not_accepted?
      linked_event.needs_improvement? ? STATUS_NEEDS_IMPROVEMENT : STATUS_SUBMITTED
    end

    def owner
      @owner ||= @target.founder_role? ? @founder : @founder.startup
    end

    def completed_prerequisites_ids
      @completed_prerequisites_ids ||= begin
        events = @founder.startup.timeline_events.verified_or_needs_improvement
        events.where(target: @target.prerequisite_targets.pluck(:id)).select(:target_id).distinct
      end
    end
  end
end
