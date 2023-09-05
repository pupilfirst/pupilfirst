class Calendar < ApplicationRecord
  belongs_to :course
  has_many :calendar_events, dependent: :destroy
  has_many :calendar_cohorts, dependent: :destroy
  has_many :cohorts, through: :calendar_cohorts

  validates_with RateLimitValidator,
                 limit: 100,
                 scope: :course_id,
                 time_frame: 1.week
end
