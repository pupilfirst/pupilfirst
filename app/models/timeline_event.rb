class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :title, :type, :eventdate, :startup_id, :iteration

  def self.valid_types
    ["a","c","e"]
  end
  validates_inclusion_of :type, in: valid_types


end
