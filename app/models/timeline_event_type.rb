class TimelineEventType < ActiveRecord::Base
  has_many :timeline_events, :dependent => :restrict_with_exception
  validates_presence_of :key, :title, :badge
  validates_uniqueness_of :key

  mount_uploader :badge, BadgeUploader

  def sample
    sample_text.present? ? sample_text : 'What\'s been happening?'
  end
end
