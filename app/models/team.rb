class Team < ApplicationRecord
  belongs_to :cohort
  has_one :course, through: :cohort
  has_one :school, through: :course
  has_many :founders, dependent: :restrict_with_error
  scope :active, -> { (where(cohort: Cohort.active)) }
end
