class Community < ApplicationRecord
  belongs_to :school

  has_many :topics, dependent: :restrict_with_error
  has_many :posts, through: :topics
  has_many :community_course_connections, dependent: :restrict_with_error
  has_many :courses, through: :community_course_connections
  has_many :users, -> { distinct }, through: :courses
  has_many :topic_categories, dependent: :destroy

  validates :name, presence: true

  normalize_attribute :name
end
