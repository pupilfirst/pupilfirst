class SubmissionComment < ApplicationRecord
  belongs_to :user
  belongs_to :submission, class_name: "TimelineEvent"
  belongs_to :hidden_by, class_name: "User", optional: true

  has_many :reactions, as: :reactionable, dependent: :destroy
  has_many :moderation_reports, as: :reportable, dependent: :destroy

  validates_with RateLimitValidator,
                 limit: 300,
                 scope: :user_id,
                 time_frame: 1.hour

  scope :not_hidden, -> { where(hidden_at: nil) }
  scope :not_archived, -> { where(archived_at: nil) }
end
