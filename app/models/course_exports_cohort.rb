class CourseExportsCohort < ApplicationRecord
  belongs_to :course_export
  belongs_to :cohort

  validates_with RateLimitValidator, limit: 100, scope: :cohort_id
end
