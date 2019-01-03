class TimelineEventGrade < ApplicationRecord
  belongs_to :timeline_event
  belongs_to :evaluation_criterion

  validates :timeline_event_id, uniqueness: { scope: :evaluation_criterion_id }
  validates :evaluation_criterion_id, uniqueness: { scope: :timeline_event_id }
  validates :grade, presence: true
end
