class TopicCategory < ApplicationRecord
  belongs_to :community
  has_many :topics, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :community_id }
end
