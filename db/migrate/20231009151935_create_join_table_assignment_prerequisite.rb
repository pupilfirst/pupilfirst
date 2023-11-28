class CreateJoinTableAssignmentPrerequisite < ActiveRecord::Migration[6.1]
  def change
    create_join_table :assignments, :prerequisite_assignments do |t|
      t.index %i[assignment_id prerequisite_assignment_id],
              name: "index_assignment_prerequisite"
      t.index %i[prerequisite_assignment_id assignment_id],
              name: "index_prerequisite_assignment"
    end
  end
end
