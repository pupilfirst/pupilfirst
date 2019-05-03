class UndoSubmissionMutator < ApplicationMutator
  attr_accessor :target_id

  validates :target_id, presence: true

  validate :must_have_pending_submission

  def undo_submission
    timeline_event.destroy!
  end

  private

  def must_have_pending_submission
    return if timeline_event.pending_review?

    errors[:base] << 'NoPendingSubmission'
  end

  def timeline_event
    @timeline_event ||= target.timeline_events.joins(:founders).where(founders: { id: current_founder }).order(created_at: :DESC).first
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  # Founders linked to a timeline event can delete it.
  def authorized?
    current_founder.present? &&
      target.present? &&
      timeline_event.present? &&
      timeline_event.founders.where(id: current_founder).exists?
  end
end
