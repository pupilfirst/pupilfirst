class Standing < ApplicationRecord
  belongs_to :school
  has_many :user_standings, dependent: :restrict_with_error

  validates :name,
            presence: true,
            uniqueness: {
              scope: :school_id,
              message: "should be unique within a school"
            },
            length: {
              maximum: 25,
              message: "should not be longer than 25 characters"
            }
  validates :description,
            presence: false,
            length: {
              maximum: 150,
              message: "should not be longer than 255 characters"
            }
  validates :color, presence: true
  validates_with RateLimitValidator, limit: 15, scope: :school_id
end
