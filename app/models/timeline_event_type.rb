class TimelineEventType < ActiveRecord::Base
  validates_presence_of :key, :title, :badge
  validates_uniqueness_of :key

  mount_uploader :badge, BadgeUploader

  def sample
    sample_text.present? ? sample_text : 'What\'s been happening?'
  end
end
