class Cohort < ApplicationRecord
  belongs_to :course
  has_many :teams, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :faculty_cohort_enrollments, dependent: :destroy
  has_many :faculty, through: :faculty_cohort_enrollments
  has_one :school, through: :course
  has_many :calendar_cohorts, dependent: :destroy
  has_many :calendars, through: :calendar_cohorts

  has_many :course_exports_cohorts, dependent: :destroy
  has_many :course_exports, through: :course_exports_cohorts

  scope :active, -> { where(ends_at: Time.zone.now...).or(where(ends_at: nil)) }
  scope :ended, -> { where(ends_at: ...Time.zone.now) }

  validates :name, presence: true, uniqueness: { scope: :course_id }

  validates_with RateLimitValidator,
                 limit: 100,
                 scope: :course_id,
                 time_frame: 1.day

  normalize_attribute :description, :name

  def ended?
    ends_at.present? && ends_at.past?
  end
end
