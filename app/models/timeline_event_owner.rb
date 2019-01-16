class TimelineEventOwner < ApplicationRecord
  belongs_to :timeline_event
  belongs_to :founder
end
