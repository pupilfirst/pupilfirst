class FacultyCourseEnrollment < ApplicationRecord
  belongs_to :faculty
  belongs_to :course
end
