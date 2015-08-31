class TimelineEventType < ActiveRecord::Base
  has_many :timeline_events, :dependent => :restrict_with_exception
  validates_presence_of :key, :title, :badge
  validates_uniqueness_of :key

  TYPE_END_ITERATION = 'end_iteration'

  TYPE_STAGE_IDEA = 'moved_to_idea_discovery'
  TYPE_STAGE_PROTOTYPE = 'moved_to_prototyping'
  TYPE_STAGE_CUSTOMER = 'moved_to_customer_validation'
  TYPE_STAGE_EFFICIENCY = 'moved_to_efficiency'
  TYPE_STAGE_SCALE = 'moved_to_scale'

  mount_uploader :badge, BadgeUploader

  attr_accessor :copy_badge_from

  before_validation do
    self.badge = TimelineEventType.find(self.copy_badge_from).badge if self.copy_badge_from.present?
  end

  def sample
    placeholder_text = sample_text.present? ? sample_text : "What's been happening?"
    placeholder_text += "\n\nProof Required: #{proof_required}" if proof_required.present?
    placeholder_text
  end

  def end_iteration?
    key == TYPE_END_ITERATION
  end

  scope :end_iteration, -> {where(key: TYPE_END_ITERATION)}
  scope :moved_to_stage, -> {where(key: [TYPE_STAGE_IDEA, TYPE_STAGE_PROTOTYPE, TYPE_STAGE_CUSTOMER, TYPE_STAGE_EFFICIENCY, TYPE_STAGE_SCALE])}
end
