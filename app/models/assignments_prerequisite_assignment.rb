class AssignmentsPrerequisiteAssignment < ApplicationRecord
  self.primary_key = :assignment_id
  belongs_to :assignment
  belongs_to :prerequisite_assignment, class_name: "Assignment"
  validates_with RateLimitValidator, limit: 25, scope: :assignment_id
end
