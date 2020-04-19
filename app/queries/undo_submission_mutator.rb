class UndoSubmissionMutator < ApplicationQuery
  property :target_id, validates: { presence: true }

  validate :must_have_pending_submission

  def undo_submission
    TimelineEvent.transaction do
      # Remove the submission
      timeline_event.destroy!

      # Set the most recent submission to latest.
      last_submission = founder.timeline_events.where(target: target).order(created_at: :desc).first
      last_submission.update!(latest: true) if last_submission.present?
    end
  end

  private

  def must_have_pending_submission
    return if timeline_event.pending_review?

    errors[:base] << 'NoPendingSubmission'
  end

  def timeline_event
    @timeline_event ||= target.timeline_events.joins(:founders).where(founders: { id: founder }).order(created_at: :DESC).first
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def founder
    @founder ||= current_user.founders.joins(:level).where(levels: { course_id: target.course }).first
  end

  # Founders linked to a timeline event can delete it.
  def authorized?
    target.present? &&
      founder.present? &&
      target.status(founder) == Targets::StatusService::STATUS_SUBMITTED
  end
end
