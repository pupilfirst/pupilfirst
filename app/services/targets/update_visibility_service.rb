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
        detach_from_prerequisites
        clear_milestone_settings
      when Target::VISIBILITY_DRAFT
        remove_as_prerequisite
        unarchive_target_group
      when Target::VISIBILITY_LIVE
        unarchive_target_group
      else
        raise "Targets::UpdateVisibilityService received unknown visiblity value '#{@visibility}'"
      end

      @target.update!(safe_to_change_visibility: true, visibility: @visibility)
    end

    private

    def detach_from_prerequisites
      TargetPrerequisite.transaction do
        Targets::DetachFromPrerequisitesService.new([@target]).execute
      end
    end

    def remove_as_prerequisite
      TargetPrerequisite.where(prerequisite_target: @target).destroy_all
    end

    def clear_milestone_settings
      @target.update!(milestone: false, milestone_number: nil)
    end

    def unarchive_target_group
      TargetGroups::ArchivalService.new(@target.target_group).unarchive
    end
  end
end
