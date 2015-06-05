class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  mount_uploader :image, TimelineImageUploader
  serialize :links
end
