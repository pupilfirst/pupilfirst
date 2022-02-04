class Post < ApplicationRecord
  belongs_to :topic
  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :editor, class_name: 'User', optional: true
  belongs_to :archiver, class_name: 'User', optional: true
  belongs_to :reply_to_post, class_name: 'Post', optional: true

  has_many :replies, class_name: 'Post', foreign_key: 'reply_to_post_id', dependent: :restrict_with_error, inverse_of: :reply_to_post
  has_many :post_likes, dependent: :restrict_with_error
  has_many :text_versions, as: :versionable, dependent: :restrict_with_error

  scope :live, -> { where(archived_at: nil) }

  delegate :community, to: :topic
end
