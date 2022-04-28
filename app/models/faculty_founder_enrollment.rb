class FacultyFounderEnrollment < ApplicationRecord
  belongs_to :faculty
  belongs_to :startup
end
