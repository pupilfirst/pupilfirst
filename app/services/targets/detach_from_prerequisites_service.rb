module Targets
  class DetachFromPrerequisitesService
    def initialize(targets)
      @targets = targets
    end

    def execute
      TargetPrerequisite.where(prerequisite_target: @targets).destroy_all
      TargetPrerequisite.where(target: @targets).destroy_all
    end
  end
end
