class AssignmentsPrerequisiteAssignment < ApplicationRecord
  belongs_to :assignment
  belongs_to :prerequisite_assignment, class_name: "Assignment"
  validates_with RateLimitValidator, limit: 25, scope: :assignment_id
end
