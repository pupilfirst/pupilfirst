module Targets
  class StatusService
    def initialize(target, founder)
      @target = target
      @founder = founder
      @level_number = founder.startup.level.number
    end

    def status
      return status_from_event if linked_event.present?

      unavailable_or_pending?
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def unavailable_or_pending?
      # Non-submittables are no-brainers.
      return Target::STATUS_UNAVAILABLE if @target.submittability == Target::SUBMITTABILITY_NOT_SUBMITTABLE

      # So are targets in higher levels
      return Target::STATUS_LEVEL_LOCKED if @target.level.number > @level_number

      # For milestone targets, ensure last levels milestones where completed
      if @target.target_group.milestone? && @target.level.number == @level_number
        return Target::STATUS_PENDING_MILESTONE unless previous_milestones_completed?
      end

      return Target::STATUS_UNAVAILABLE if pending_prerequisites.exists?

      Target::STATUS_PENDING
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def previous_milestones_completed?
      @previous_milestones_completed ||= begin
        return true unless @level_number > 1

        previous_level = @founder.startup.school.levels.find_by(number: @level_number - 1)
        target_groups = previous_level.target_groups.where(milestone: true)
        milestone_targets = Target.where(target_group: target_groups)
        completed_target_ids = TimelineEvent.verified_or_needs_improvement.where(target: milestone_targets).pluck('target_id').uniq
        @target.id.in?(completed_target_ids)
      end
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
      return  Target::STATUS_COMPLETE if linked_event.verified?
      return  Target::STATUS_NOT_ACCEPTED if linked_event.not_accepted?

      linked_event.needs_improvement? ? Target::STATUS_NEEDS_IMPROVEMENT : Target::STATUS_SUBMITTED
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
