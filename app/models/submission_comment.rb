class SubmissionComment < ApplicationRecord
  belongs_to :user
  belongs_to :timeline_event
  has_many :reactions, as: :reactionable, dependent: :destroy
  has_many :moderation_reports, as: :reportable, dependent: :destroy

  scope :not_archived, -> { where(archived_at: nil) }
end
