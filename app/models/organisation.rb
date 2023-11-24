class Organisation < ApplicationRecord
  belongs_to :school
  has_and_belongs_to_many :users, through: :organisations_users
  has_many :students, through: :users
  has_many :cohorts, through: :students
  has_many :organisation_admins, dependent: :restrict_with_error

  validates_with RateLimitValidator,
                 limit: 100,
                 scope: :school_id,
                 time_frame: 1.day
end
