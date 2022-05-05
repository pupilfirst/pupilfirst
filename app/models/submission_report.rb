class SubmissionReport < ApplicationRecord
  belongs_to :submission, class_name: 'TimelineEvent'

  validates :status, presence: true

  validate :completed_state_is_valid

  validate :in_progress_state_is_valid

  validate :queued_state_is_valid

  enum status: {
         queued: 'queued',
         in_progress: 'in_progress',
         completed: 'completed'
       }

  enum conclusion: { success: 'success', failure: 'failure', error: 'error' }

  def queued_state_is_valid
    return unless queued?

    return if [started_at, completed_at, conclusion].all?(&:blank?)

    errors.add(:status, 'invalid queued report status')
  end

  def in_progress_state_is_valid
    return unless in_progress?

    return if started_at.present? && [completed_at, conclusion].all?(&:blank?)

    errors.add(:status, 'invalid in-progress report status')
  end

  def completed_state_is_valid
    return unless completed?

    return if [started_at, completed_at, conclusion].all?(&:present?)

    errors.add(:status, 'invalid completed report status')
  end
end
