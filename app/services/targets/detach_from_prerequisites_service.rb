module Targets
  class DetachFromPrerequisitesService
    def initialize(target)
      @target = target
    end

    def execute
      TargetPrerequisite.where(prerequisite_target: @target).destroy_all
    end
  end
end
