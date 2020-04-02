class Post < ApplicationRecord
  belongs_to :topic
  belongs_to :creator, class_name: 'User'
  belongs_to :editor, class_name: 'User', optional: true
  belongs_to :archiver, class_name: 'User', optional: true
  belongs_to :reply_to_post, class_name: 'Post', optional: true

  has_many :post_likes, dependent: :restrict_with_error
end
