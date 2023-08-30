class FacultyStudentEnrollment < ApplicationRecord
  belongs_to :faculty
  belongs_to :student
  validates_with RateLimitValidator, limit: 100, scope: :faculty_id
end
