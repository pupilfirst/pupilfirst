module Targets
  class BulkStatusService
    STATUS_COMPLETE = :complete
    STATUS_NEEDS_IMPROVEMENT = :needs_improvement
    STATUS_SUBMITTED = :submitted
    STATUS_PENDING = :pending
    STATUS_UNAVAILABLE = :unavailable
    STATUS_NOT_ACCEPTED = :not_accepted

    def initialize(founder)
      @founder = founder
    end

    # returns array of all 'submitted' target_ids and statuses
    # note: all targets missing will have a 'pending' status
    def statuses
      event_statuses_for_all_targets.map do |target_id, event_status|
        status = begin
          if prerequisites_pending?(target_id)
            STATUS_UNAVAILABLE
          else
            case event_status
              when TimelineEvent::VERIFIED_STATUS_VERIFIED then STATUS_COMPLETE
              when TimelineEvent::VERIFIED_STATUS_NOT_ACCEPTED then STATUS_NOT_ACCEPTED
              when TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT then STATUS_NEEDS_IMPROVEMENT
              else STATUS_SUBMITTED
            end
          end
        end
        [target_id, status]
      end
    end

    private

    # all submitted founder target_ids and status of corresponding latest events
    def event_statuses_for_founder_targets
      @event_statuses_for_founder_targets ||= @founder.timeline_events.where.not(target_id: nil)
        .where(target: Target.founder)
        .select("DISTINCT ON(target_id) *").order("target_id, created_at DESC")
        .map { |event| [event.target_id, event.verified_status] }
    end

    # all submitted startup target_ids and status of corresponding latest events
    def event_statuses_for_startup_targets
      @event_statuses_for_startup_targets ||= @founder.startup.timeline_events.where.not(target_id: nil)
        .where(target: Target.not_founder)
        .select("DISTINCT ON(target_id) *").order("target_id, created_at DESC")
        .map { |event| [event.target_id, event.verified_status] }
    end

    # All submitted target_ids and status of corresponding latest events
    def event_statuses_for_all_targets
      event_statuses_for_founder_targets + event_statuses_for_startup_targets
    end

    def prerequisites_pending?(target_id)
      # nothing pending if no prerequisites to begin with
      return false unless target_id.in?(targets_with_prerequisites)

      # prerequisites are definitely pending unless every one of them has submissions
      prerequisite_target_ids = target_prerequisites.select { |e| e[0] == target_id }.map(&:second)
      submitted_target_ids = event_statuses_for_all_targets.map(&:first)
      return true if (prerequisite_target_ids - submitted_target_ids).present?

      # none of the prerequisite submissions should be pending or not accepted
      statuses_for_prerequisites = event_statuses_for_all_targets.select { |e| e[0].in?(prerequisite_target_ids) }.map(&:second)
      (['Pending', 'Not Accepted'] & statuses_for_prerequisites).present?
    end

    # all target prerequisite mappings
    def target_prerequisites
      @target_prerequisites ||= TargetPrerequisite.all.pluck(:target_id, :prerequisite_target_id)
    end

    # all targets with prerequisites
    def targets_with_prerequisites
      target_prerequisites.map(&:first)
    end
  end
end
