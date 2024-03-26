class Team < ApplicationRecord
  belongs_to :cohort
  has_one :course, through: :cohort
  has_one :school, through: :course
  has_many :students, dependent: :restrict_with_error
  scope :active, -> { (where(cohort: Cohort.active)) }
  scope :inactive, -> { (where.not(cohort: Cohort.active)) }
  validates_with RateLimitValidator,
                 limit: 2500,
                 scope: :cohort_id,
                 time_frame: 1.hour
end
