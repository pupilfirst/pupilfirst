class SubmissionComment < ApplicationRecord
  belongs_to :user
  belongs_to :timeline_event
  has_many :reactions, as: :reactionable, dependent: :destroy
end
