module Targets
  # Clean-up references to the target in the TargetPrerequisite join table.
  class ArchivalService
    def initialize(target)
      @target = target
    end

    def archive
      TargetPrerequisite.transaction do
        target_prerequisites = TargetPrerequisite.where('target_id = ? OR prerequisite_target_id = ?', @target.id, @target.id)
        target_prerequisites.destroy_all if target_prerequisites.exists?
        @target.update!(safe_to_archive: true, archived: true)
      end
    end

    def unarchive
      TargetGroups::ArchivalService.new(@target.target_group).unarchive
      @target.update!(archived: false)
    end
  end
end
