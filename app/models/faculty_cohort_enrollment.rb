class FacultyCohortEnrollment < ApplicationRecord
  belongs_to :faculty
  belongs_to :cohort

  validates_with RateLimitValidator, limit: 100, scope: :faculty_id
end
