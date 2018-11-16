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
      @linked_event ||= @founder.latest_submissions.find_by(target: @target)
    end

    def status_from_event
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

      previous_level_milestones = Target.joins(:target_group).where(
        target_groups: {
          level: previous_level,
          milestone: true
        }
      )

      previous_level_passed_milestones = previous_level_milestones.joins(latest_submission_records: :timeline_event).where(
        latest_submission_records: {
          founder: @founder
        }
      ).where.not(
        latest_submission_records: {
          timeline_events: {
            passed_at: nil
          }
        }
      )

      previous_level_milestones.count != previous_level_passed_milestones.count
    end

    def prerequisites_incomplete?
      passed_prerequisites = @target.prerequisite_targets.joins(latest_submission_records: :timeline_event).where(
        latest_submission_records: {
          founder: @founder
        }
      ).where.not(
        latest_submission_records: {
          timeline_events: {
            passed_at: nil
          }
        }
      )
      passed_prerequisites.count != @target.prerequisite_targets.count
    end
  end
end
