class ApplicationSubmissionUrl < ActiveRecord::Base
  belongs_to :application_submission

  validates :name, presence: true
  validates :url, presence: true
  validates :application_submission_id, presence: true
  validates :score, numericality: true, allow_nil: true

  after_commit :add_score_to_submission

  def add_score_to_submission
    application_submission.update_score! if previous_changes.key?(:score)
  end
end
