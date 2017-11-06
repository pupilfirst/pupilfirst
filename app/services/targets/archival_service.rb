module Targets
  class ArchivalService
    def initialize(target)
      @target = target
    end

    def archive
      # Clean-up entries reference of the target in the TargetPrerequisite join table
      TargetPrerequisite.transaction do
        target_prerequisites = TargetPrerequisite.where('target_id = ? OR prerequisite_target_id = ?', @target.id, @target.id)
        target_prerequisites.destroy_all if target_prerequisites.present?
        @target.update!(archived: true)
      end
    end

    def unarchive
      @target.update!(archived: false)
    end
  end
end
