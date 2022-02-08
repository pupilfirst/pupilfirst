class SubmissionReport < ApplicationRecord
  belongs_to :submission, class_name: 'TimelineEvent'

  validates :status, presence: true

  enum status: {
         queued: 'queued',
         in_progress: 'in_progress',
         completed: 'completed'
       }

  enum conclusion: { success: 'success', failure: 'failure', error: 'error' }

  validate :queued_state_is_valid

  def queued_state_is_valid
    return unless queued?

    return if [started_at, completed_at, conclusion].all?(&:blank?)

    errors[:status] << 'invalid queued report status'
  end

  validate :in_progress_state_is_valid

  def in_progress_state_is_valid
    return unless in_progress?

    return if started_at.present? && [completed_at, conclusion].all?(&:blank?)

    errors[:status] << 'invalid in-progress report status'
  end

  validate :completed_state_is_valid

  def completed_state_is_valid
    return unless completed?

    return if [started_at, completed_at, conclusion].all?(&:present?)

    errors[:status] << 'invalid completed report status'
  end
end
