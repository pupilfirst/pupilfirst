class Event < ActiveRecord::Base
  belongs_to :location
  belongs_to :category
  mount_uploader :picture, FeedImageUploader
  just_define_datetime_picker :start_at
  just_define_datetime_picker :end_at

  normalize_attributes :title, :description, :start_at, :end_at, :featured, :picture

end
