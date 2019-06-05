class Community < ApplicationRecord
  belongs_to :school
  has_many :courses, dependent: :restrict_with_error
  has_many :questions, dependent: :restrict_with_error
  has_many :community_course_connections, dependent: :restrict_with_error
  has_many :courses, through: :community_course_connections

  validates :name, presence: true

  normalize_attribute :name
end
