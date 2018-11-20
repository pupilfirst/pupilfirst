class LatestSubmissionRecord < ApplicationRecord
  belongs_to :founder
  belongs_to :target
  belongs_to :timeline_event

  validates :founder_id, uniqueness: { scope: :target_id }
  validates :target_id, uniqueness: { scope: :founder_id }
end
