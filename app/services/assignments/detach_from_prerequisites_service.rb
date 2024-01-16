module Assignments
  class DetachFromPrerequisitesService
    def initialize(assignments)
      @assignments = assignments
    end

    def execute
      AssignmentsPrerequisiteAssignment
        .where(prerequisite_assignment: @assignments)
        .or(AssignmentsPrerequisiteAssignment.where(assignment: @assignments))
        .delete_all
    end
  end
end
