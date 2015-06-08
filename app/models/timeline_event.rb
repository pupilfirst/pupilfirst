class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :title, :type, :event_on, :startup_id, :iteration

  def self.valid_types
    ["a","c","e"]
  end

  validates_inclusion_of :type, in: valid_types

  scope :belongs_to_iteration, ->(i) { where(:iteration => i)}
end
