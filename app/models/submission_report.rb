class SubmissionReport < ApplicationRecord
  VIRTUAL_TEACHING_ASSISTANT = "Virtual Teaching Assistant".freeze
  belongs_to :submission, class_name: "TimelineEvent"

  validates :status, presence: true

  validate :completed_state_is_valid

  validate :in_progress_state_is_valid

  validate :queued_state_is_valid

  validates_with RateLimitValidator, limit: 25, scope: :submission_id

  enum status: {
         queued: "queued",
         in_progress: "in_progress",
         success: "success",
         failure: "failure",
         error: "error"
       }

  def conclusion_statuses
    %w[success failure error]
  end

  def queued_state_is_valid
    return unless queued?

    return if [started_at, completed_at].all?(&:blank?)

    errors.add(:status, "invalid queued report status")
  end

  def in_progress_state_is_valid
    return unless in_progress?

    return if started_at.present? && [completed_at].all?(&:blank?)

    errors.add(:status, "invalid in-progress report status")
  end

  def completed_state_is_valid
    return unless (success? || failure? || error?)

    return if [started_at, completed_at].all?(&:present?)

    errors.add(:status, "invalid #{status} report status")
  end
end
