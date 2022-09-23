class Cohort < ApplicationRecord
  belongs_to :course
  has_many :teams, dependent: :destroy
  has_many :founders, dependent: :destroy
  has_many :faculty_cohort_enrollments, dependent: :destroy
  has_many :faculty, through: :faculty_cohort_enrollments
  has_one :school, through: :course

  scope :active,
        -> { where('ends_at > ?', Time.zone.now).or(where(ends_at: nil)) }
  scope :ended, -> { where('ends_at < ?', Time.zone.now) }

  normalize_attribute :description

  def ended?
    ends_at.present? && ends_at.past?
  end
end
