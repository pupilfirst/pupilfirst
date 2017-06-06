class ApplicationSubmissionUrl < ApplicationRecord
  belongs_to :application_submission

  # Is scored by
  belongs_to :admin_user, optional: true

  validates :name, presence: true
  validates :url, presence: true, url: true
  validates :application_submission_id, presence: true
  validates :score, numericality: true, allow_nil: true
  validates :admin_user_id, presence: true, if: proc { |application_submission_url| application_submission_url.score.present? }

  after_commit :add_score_to_submission

  def add_score_to_submission
    application_submission.update_score! if previous_changes.key?(:score)
  end
end
