class SubmissionComment < ApplicationRecord
  belongs_to :user
  belongs_to :timeline_event
  belongs_to :hidden_by, class_name: "User", optional: true

  has_many :reactions, as: :reactionable, dependent: :destroy
  has_many :moderation_reports, as: :reportable, dependent: :destroy

  scope :not_hidden, -> { where(hidden_at: nil) }
end
