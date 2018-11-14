module Targets
  class StatusService
    STATUS_PASSED = :passed
    STATUS_FAILED = :failed
    STATUS_SUBMITTED = :submitted
    STATUS_PENDING = :pending
    STATUS_LEVEL_LOCKED = :level_locked
    STATUS_PREREQUISITE_LOCKED = :prerequisite_locked
    STATUS_MILESTONE_LOCKED = :milestone_locked

    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def status
      return status_from_event if linked_event.present?

      reason_to_lock || STATUS_PENDING
    end

    private

    def linked_event
      @linked_event ||= @target.latest_linked_event(@founder)
    end

    def status_from_event
      # TODO: Replace 'evaluated_at' with `passed_at` and write one-off to fix existing data.
      return STATUS_PASSED if linked_event.passed_at?

      linked_event.evaluator_id? ? STATUS_FAILED : STATUS_SUBMITTED
    end

    def reason_to_lock
      @reason_to_lock ||= begin
        return STATUS_LEVEL_LOCKED if target_level_number > founder_level_number

        return STATUS_MILESTONE_LOCKED if current_level_milestone? && previous_milestones_incomplete?

        prerequisites_incomplete? ? STATUS_PREREQUISITE_LOCKED : nil
      end
    end

    def founder_level_number
      @founder_level_number ||= @founder.level.number
    end

    def target_level_number
      @target_level_number ||= @target.level.number
    end

    def current_level_milestone?
      @target.target_group.milestone? && target_level_number == founder_level_number
    end

    def previous_milestones_incomplete?
      return false if founder_level_number == 1

      previous_level = @target.school.levels.where(number: founder_level_number - 1)
      milestone_targets = Target.where(target_group: TargetGroup.where(level: previous_level, milestone: true))
      # TODO: Optimize this using a 'latest_submissions' join table.
      milestone_targets.any? { |target| target.latest_linked_event(@founder).passed_at.nil? }
    end

    def prerequisites_incomplete?
      @target.prerequisite_targets.any? { |target| target.latest_linked_event(@founder).passed_at.nil? }

      # TODO: Optimize this using a 'latest_submissions' join table.
      # @target.prerequisite_targets.joins(latest_submissions: :timeline_event).where(latest_submissions: { founder_id: @founder.id }).where(timeline_events: { passed_at: nil }).exists?
    end
  end
end
