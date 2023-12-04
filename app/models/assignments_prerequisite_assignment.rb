class AssignmentsPrerequisiteAssignment < ApplicationRecord
  belongs_to :assignment
  belongs_to :prerequisite_assignment, class_name: "Assignment"
end
