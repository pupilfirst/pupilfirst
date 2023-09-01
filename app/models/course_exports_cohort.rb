class CourseExportsCohort < ApplicationRecord
  belongs_to :course_export
  belongs_to :cohort
end
