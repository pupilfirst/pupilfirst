class UndoSubmissionMutator < ApplicationQuery
  property :target_id, validates: { presence: true }

  validate :must_have_pending_submission

  def undo_submission
    TimelineEvent.transaction do
      owners = timeline_event.students.load

      # Remove the submission
      timeline_event.update!(archived_at: Time.zone.now)
      timeline_event.timeline_event_owners.each do |owner|
        owner.update!(latest: false)
      end

      # Set the most recent submission to latest.
      owners.each do |owner|
        timeline_event =
          owner
            .timeline_events
            .live
            .where(target: target)
            .order(:created_at)
            .last

        next if timeline_event.blank?

        TimelineEventOwner.where(
          student: owner,
          timeline_event: timeline_event
        ).update(latest: true)
      end
    end
  end

  private

  def must_have_pending_submission
    return if timeline_event.pending_review?

    errors.add(:base, "NoPendingSubmission")
  end

  def timeline_event
    @timeline_event ||=
      target
        .timeline_events
        .live
        .joins(:students)
        .where(students: { id: student })
        .order(created_at: :DESC)
        .first
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def student
    @student ||=
      current_user
        .students
        .joins(:cohort)
        .where(cohorts: { course_id: target.course })
        .first
  end

  # Students linked to a timeline event can delete it and submission should be live.
  def authorized?
    target.present? && student.present? && timeline_event.present? &&
      !target.status(student).in?(
        [
          Targets::StatusService::STATUS_PASSED,
          Targets::StatusService::STATUS_FAILED
        ]
      )
  end
end
