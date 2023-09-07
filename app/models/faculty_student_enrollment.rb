class FacultyStudentEnrollment < ApplicationRecord
  belongs_to :faculty
  belongs_to :student

  validates :faculty_id, uniqueness: { scope: :student_id }
end
