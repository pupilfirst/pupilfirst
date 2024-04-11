module Targets
  class StatusService
    STATUS_PASSED = :passed
    STATUS_FAILED = :failed
    STATUS_SUBMITTED = :submitted
    STATUS_PENDING = :pending
    STATUS_SUBMISSION_LIMIT_LOCKED = :submission_limit_locked
    STATUS_PREREQUISITE_LOCKED = :prerequisite_locked
    STATUS_COURSE_LOCKED = :course_locked
    STATUS_ACCESS_LOCKED = :access_locked

    def initialize(target, student)
      @target = target
      @student = student
    end

    def status
      reason_to_lock.presence || status_from_event.presence || STATUS_PENDING
    end

    def status_from_event
      return if linked_event.blank?
      return STATUS_PASSED if linked_event.passed_at?

      linked_event.evaluated_at ? STATUS_FAILED : STATUS_SUBMITTED
    end

    private

    def linked_event
      @linked_event ||=
        @student
          .latest_submissions
          .where(target: @target)
          .order(created_at: :desc)
          .find do |submission|
            if @target.individual_target?
              true
            else
              submission.student_ids.sort == @student.team_student_ids
            end
          end
    end

    def assignment
      return @assignment if defined?(@assignment)
      @assignment = @target.assignments.not_archived.first
    end

    def reason_to_lock
      @reason_to_lock ||=
        begin
          if @target.course.ended?
            STATUS_COURSE_LOCKED
          elsif @student.cohort.ended?
            STATUS_ACCESS_LOCKED
          elsif target_reviewed? && @target.course.progression_limit != 0 &&
                @target.course.progression_limit <=
                  @student.timeline_events.pending_review.count
            STATUS_SUBMISSION_LIMIT_LOCKED
          else
            prerequisites_incomplete? ? STATUS_PREREQUISITE_LOCKED : nil
          end
        end
    end

    def target_level_number
      @target_level_number ||= @target.level.number
    end

    def target_reviewed?
      return @target_reviewed if defined?(@target_reviewed)
      @target_reviewed = assignment && assignment.evaluation_criteria.any?
    end

    def prerequisites_incomplete?
      applicable_assignments =
        assignment
          .prerequisite_assignments
          .not_archived
          .joins(:target)
          .where(target: { visibility: Target::VISIBILITY_LIVE })

      submitted_prerequisites =
        applicable_assignments.joins(
          timeline_events: :timeline_event_owners
        ).where(
          timeline_events: {
            archived_at: nil,
          },
          timeline_event_owners: {
            student_id: @student.id,
            latest: true
          }
        )

      submitted_prerequisites.count != applicable_assignments.count
    end
  end
end
