class News < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: :user_id

  mount_uploader :picture, FeedImageUploader

end
