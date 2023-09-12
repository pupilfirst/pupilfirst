class FacultyCohortEnrollment < ApplicationRecord
  belongs_to :faculty
  belongs_to :cohort

  validates :faculty_id, uniqueness: { scope: :cohort_id }
end
