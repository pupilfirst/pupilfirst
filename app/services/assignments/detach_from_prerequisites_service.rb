module Assignments
  class DetachFromPrerequisitesService
    def initialize(assignments)
      @assignments = assignments
    end

    def execute
      AssignmentPrerequisite
        .where(prerequisite_assignment: @assignments)
        .or(AssignmentPrerequisite.where(assignment: @assignments))
        .delete_all
    end
  end
end
