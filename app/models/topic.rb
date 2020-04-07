class Topic < ApplicationRecord
  include PgSearch::Model

  belongs_to :community
  belongs_to :target, optional: true

  has_many :posts, dependent: :restrict_with_error
  has_many :text_versions, as: :versionable, dependent: :restrict_with_error
  has_one :first_post, -> { where post_number: 1 }, class_name: 'Post', inverse_of: :topic
  has_many :replies, -> { where('post_number > ?', 1) }, class_name: 'Post', inverse_of: :topic
  has_many :post_likes, through: :posts

  scope :live, -> { where(archived: false) }

  delegate :creator, to: :first_post

  pg_search_scope :search_by_title, against: :title, using: {
    tsearch: { prefix: true, any_word: true }
  }

  def solution
    replies.find_by(solution: true)
  end
end
