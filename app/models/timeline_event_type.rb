class TimelineEventType < ActiveRecord::Base
  validates_presence_of :key, :title
end
