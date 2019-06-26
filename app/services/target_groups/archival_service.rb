module TargetGroups
  # Ensures that all targets in the group are archived before the group is archived.
  class ArchivalService
    def initialize(target_group)
      @target_group = target_group
    end

    def archive
      TargetGroup.transaction do
        @target_group.targets.live.each { |target| Targets::UpdateVisibilityService.new(target, Target::VISIBILITY_ARCHIVED).execute }
        @target_group.update!(safe_to_archive: true, archived: true)
      end
    end

    def unarchive
      @target_group.update!(archived: false)
    end
  end
end
