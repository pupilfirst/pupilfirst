module Targets
  class DetachFromPrerequisitesService
    def initialize(targets)
      @targets = targets
    end

    def execute
      AssignmentPrerequisite.where(prerequisite_assignment: assignments).or(AssignmentPrerequisite.where(assignment: assignments)).delete_all
    end

    def assignments
      Assignment.where(target: @targets)
    end
  end
end
