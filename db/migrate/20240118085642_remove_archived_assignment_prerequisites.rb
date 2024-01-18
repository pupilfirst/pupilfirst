class RemoveArchivedAssignmentPrerequisites < ActiveRecord::Migration[7.0]
  def up
      archived_assignments = Assignment.where(archived: true)
      AssignmentsPrerequisiteAssignment
        .where(prerequisite_assignment: archived_assignments)
        .or(
          AssignmentsPrerequisiteAssignment.where(
            assignment: archived_assignments
          )
        )
        .delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
