class AssignmentPrerequisite < ApplicationRecord
  #TODO - figure out what is wrong with automatic table name
  self.table_name = "assignments_prerequisite_assignments"
  belongs_to :assignment
  belongs_to :prerequisite_assignments, class_name: "Assignment"
end
