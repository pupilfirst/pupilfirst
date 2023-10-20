class AssignmentPrerequisite < ApplicationRecord
  self.table_name = "assignments_prerequisite_assignments"
  belongs_to :assignment
  belongs_to :prerequisite_assignments, class_name: "Assignment"
end
