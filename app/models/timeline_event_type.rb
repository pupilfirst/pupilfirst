class TimelineEventType < ActiveRecord::Base
  validates_presence_of :key, :title
  validates_uniqueness_of :key
end
