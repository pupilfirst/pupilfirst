module Targets
  # Clean-up references to the target in the TargetPrerequisite join table.
  class UpdateVisibilityService
    def initialize(target, visibility)
      @target = target
      @visibility = visibility
    end

    def execute
      case @visibility
      when Target::VISIBILITY_ARCHIVED
        remove_target_prerequisites
      when Target::VISIBILITY_DRAFT, Target::VISIBILITY_LIVE
        unarchive_target_group
      else
        raise "Targets::UpdateVisibilityService received unknown visiblity value '#{@visibility}'"
      end

      @target.update!(safe_to_change_visibility: true, visibility: @visibility)
    end

    private

    def remove_target_prerequisites
      TargetPrerequisite.transaction do
        target_prerequisites =
          TargetPrerequisite.where(
            'target_id = ? OR prerequisite_target_id = ?',
            @target.id,
            @target.id
          )
        target_prerequisites.destroy_all if target_prerequisites.exists?
      end
    end

    def unarchive_target_group
      TargetGroups::ArchivalService.new(@target.target_group).unarchive
    end
  end
end
