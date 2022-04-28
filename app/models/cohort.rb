class Cohort < ApplicationRecord
  belongs_to :course
  has_many :teams, dependent: :destroy
  has_many :founders, dependent: :destroy
  has_many :faculty_cohort_enrollments, dependent: :destroy
  has_many :faculty, through: :faculty_cohort_enrollments

  scope :active,
        -> { where('ends_at > ?', Time.zone.now).or(where(ends_at: nil)) }
end
