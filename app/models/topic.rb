class Topic < ApplicationRecord
  belongs_to :community
  belongs_to :target, optional: true

  has_many :posts, dependent: :restrict_with_error

  def first_post
    posts.find_by(post_number: 1)
  end
end
