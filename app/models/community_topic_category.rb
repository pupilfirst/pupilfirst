class CommunityTopicCategory < ApplicationRecord
  belongs_to :community
  has_many :topics, dependent: :restrict_with_error

  validates :name, presence: true
end
