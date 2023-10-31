class Standing < ApplicationRecord
  belongs_to :school
  has_many :user_standings, dependent: :restrict_with_error

  validates :name,
            presence: true,
            uniqueness: {
              scope: :school_id,
              message: "name should be unique within a school"
            }
  validates :color, presence: true
  validates_with RateLimitValidator, limit: 15, scope: :school_id
end
