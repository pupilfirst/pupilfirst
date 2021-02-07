module Targets
  class StatusService
    STATUS_PASSED = :passed
    STATUS_FAILED = :failed
    STATUS_SUBMITTED = :submitted
    STATUS_PENDING = :pending
    STATUS_LEVEL_LOCKED = :level_locked
    STATUS_PREREQUISITE_LOCKED = :prerequisite_locked
    STATUS_COURSE_LOCKED = :course_locked
    STATUS_ACCESS_LOCKED = :access_locked

    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def status
      reason_to_lock.presence ||
        status_from_event.presence ||
        STATUS_PENDING
    end

    private

    def linked_event
      @linked_event ||= @founder.latest_submissions
        .where(target: @target)
        .order(created_at: :desc).find do |submission|
        @target.individual_target? ? true : submission.founder_ids.sort == @founder.team_student_ids
      end
    end

    def status_from_event
      return if linked_event.blank?
      return STATUS_PASSED if linked_event.passed_at?

      linked_event.evaluated_at ? STATUS_FAILED : STATUS_SUBMITTED
    end

    def reason_to_lock
      @reason_to_lock ||= begin
        if @target.course.ends_at&.past?
          STATUS_COURSE_LOCKED
        elsif @founder.startup.access_ends_at&.past?
          STATUS_ACCESS_LOCKED
        elsif target_level_number > founder_level_number && target_reviewed?
          STATUS_LEVEL_LOCKED
        else
          prerequisites_incomplete? ? STATUS_PREREQUISITE_LOCKED : nil
        end
      end
    end

    def founder_level_number
      @founder_level_number ||= @founder.level.number
    end

    def target_level_number
      @target_level_number ||= @target.level.number
    end

    def target_reviewed?
      @target_reviewed ||= @target.evaluation_criteria.any?
    end

    def prerequisites_incomplete?
      applicable_targets = @target.prerequisite_targets.live

      passed_prerequisites = applicable_targets.joins(timeline_events: :timeline_event_owners).where(
        timeline_event_owners: {
          founder_id: @founder.id,
          latest: true
        }
      ).where.not(
        timeline_events: {
          passed_at: nil
        }
      )

      passed_prerequisites.count != applicable_targets.count
    end
  end
end
