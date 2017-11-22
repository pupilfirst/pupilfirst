class TimelineEventGrade < ApplicationRecord
  belongs_to :timeline_event
  belongs_to :performance_criterion
end
