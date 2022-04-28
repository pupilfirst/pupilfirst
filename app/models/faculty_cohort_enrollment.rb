class FacultyCohortEnrollment < ApplicationRecord
  belongs_to :faculty
  belongs_to :cohort
end
