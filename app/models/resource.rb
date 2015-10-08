class Resource < ActiveRecord::Base
  has_and_belongs_to_many :startups

  validates_presence_of :file, :thumbnail, :title, :description

  mount_uploader :file, ResourceFileUploader
  mount_uploader :thumbnail, ResourceThumbnailUploader
  process_in_background :thumbnail
end
