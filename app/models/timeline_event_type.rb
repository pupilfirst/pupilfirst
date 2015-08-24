class TimelineEventType < ActiveRecord::Base
  has_many :timeline_events, :dependent => :restrict_with_exception
  validates_presence_of :key, :title, :badge
  validates_uniqueness_of :key

  TYPE_END_ITERATION = 'end_iteration'

  mount_uploader :badge, BadgeUploader

  attr_accessor :copy_badge_from

  before_validation do
    self.badge = TimelineEventType.find(self.copy_badge_from).badge if self.copy_badge_from.present?
  end

  def sample
    sample_text.present? ? sample_text : "What's been happening?"
  end

  def end_iteration?
    key == TYPE_END_ITERATION
  end
end
