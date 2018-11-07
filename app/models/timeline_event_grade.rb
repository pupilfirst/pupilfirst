class TimelineEventGrade < ApplicationRecord
  belongs_to :timeline_event
  belongs_to :evaluation_criterion

  validates :grade, presence: true
end
