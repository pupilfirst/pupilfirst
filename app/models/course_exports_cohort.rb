class CourseExportsCohort < ApplicationRecord
  belongs_to :course_export
  belongs_to :cohort

  validates :course_export_id, uniqueness: { scope: :cohort_id }
end
