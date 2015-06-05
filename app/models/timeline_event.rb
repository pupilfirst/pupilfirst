class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :title, :type, :eventdate, :startup_id, :iteration
end
