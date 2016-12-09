module Targets
  class StatusService
    STATUS_COMPLETE = :complete
    STATUS_NEEDS_IMPROVEMENT = :needs_improvement
    STATUS_SUBMITTED = :submitted
    STATUS_EXPIRED = :expired
    STATUS_PENDING = :pending
    STATUS_UNAVAILABLE = :unavailable
    STATUS_NOT_ACCEPTED = :not_accepted

    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def status
      return status_from_event if linked_event.present?
      return STATUS_UNAVAILABLE if pending_prerequisites.present?
      @target.due_date.past? ? STATUS_EXPIRED : STATUS_PENDING
    end

    def completed_prerequisites
      Target.where(id: completed_prerequisites_ids)
    end

    def pending_prerequisites
      @target.prerequisite_targets.where.not(id: completed_prerequisites_ids)
    end

    private

    def status_from_event
      return STATUS_COMPLETE if linked_event.verified?
      return STATUS_NOT_ACCEPTED if linked_event.not_accepted?
      linked_event.needs_improvement? ? STATUS_NEEDS_IMPROVEMENT : STATUS_SUBMITTED
    end

    def linked_event
      @linked_event ||= owner.timeline_events.where(target: @target).last
    end

    def owner_events
      owner.timeline_events.verified_or_needs_improvement
    end

    def owner
      @owner ||= @target.founder? ? @founder : @founder.startup
    end

    def completed_prerequisites_ids
      @completed_prerequisites_ids ||= begin
        owner_events.where(target: @target.prerequisite_targets.pluck(:id)).select(:target_id).distinct
      end
    end
  end
end
