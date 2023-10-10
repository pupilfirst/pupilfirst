class CreateJoinTableAssignmentPrerequisite < ActiveRecord::Migration[6.1]
  def change
    create_join_table :assignments, :prerequisite_assignments do |t|
      t.index [:assignment_id, :prerequisite_assignment_id]
      t.index [:prerequisite_assignment_id, :assignment_id]
    end
  end
end
