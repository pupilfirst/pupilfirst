class AssignmentPrerequisite < ApplicationRecord
  belongs_to :assignment
  belongs_to :prerequisite_assignments, class_name: "Assignment"
end
