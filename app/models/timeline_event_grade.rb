class TimelineEventGrade < ApplicationRecord
  belongs_to :timeline_event
  belongs_to :skill

  validates :grade, presence: true
end
