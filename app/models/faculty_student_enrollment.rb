class FacultyStudentEnrollment < ApplicationRecord
  belongs_to :faculty
  belongs_to :student
end
