class TimelineEventType < ActiveRecord::Base
  has_many :timeline_events, :dependent => :restrict_with_exception
  validates_presence_of :key, :title, :badge
  validates_uniqueness_of :key

  TYPE_END_ITERATION = 'end_iteration'
  TYPE_END_IDEA_STG = 'end_of_idea_stage'
  TYPE_END_PROTOTYPE_STG = 'end_of_prototype_stage'
  TYPE_END_CUSTOMER_STG = 'end_of_customer_stage'
  TYPE_END_EFFICIENCY_STG = 'end_of_efficiency_stage'
  TYPE_END_SCALE_STG = 'end_of_scale_stage'

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

  scope :end_iteration, -> {where(key: TYPE_END_ITERATION)}
  scope :end_of_stage, -> {where(key: [TYPE_END_IDEA_STG, TYPE_END_PROTOTYPE_STG, TYPE_END_CUSTOMER_STG, TYPE_END_EFFICIENCY_STG, TYPE_END_SCALE_STG])}

end
