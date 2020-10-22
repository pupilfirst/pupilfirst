class Topic < ApplicationRecord
  include PgSearch::Model

  belongs_to :community
  belongs_to :target, optional: true
  belongs_to :topic_category, optional: true

  has_many :posts, dependent: :restrict_with_error
  has_one :first_post, -> { where post_number: 1 }, class_name: 'Post', inverse_of: :topic
  has_one :creator, through: :first_post
  has_many :replies, -> { where('post_number > ?', 1) }, class_name: 'Post', inverse_of: :topic
  has_many :live_replies, -> { where('post_number > ?', 1).merge(Post.live) }, class_name: 'Post', inverse_of: :topic
  has_many :post_likes, through: :posts

  scope :live, -> { where(archived: false) }

  pg_search_scope :search_by_title, against: :title, using: { tsearch: { prefix: true, any_word: true }, }

  def solution
    replies.find_by(solution: true)
  end
end
