class RemoveArchivedAssignmentPrerequisites < ActiveRecord::Migration[7.0]
  def up
    # delete all prerequisite records where the prerequisites have been archived
    AssignmentsPrerequisiteAssignment
      .joins(:prerequisite_assignment)
      .where("assignments.archived = ?", true)
      .delete_all

    # delete all prerequisite records for the assignments that have been archived
    AssignmentsPrerequisiteAssignment
      .joins(:assignment)
      .where("assignments.archived = ?", true)
      .delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
