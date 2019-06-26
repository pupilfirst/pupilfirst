module Targets
  # Clean-up references to the target in the TargetPrerequisite join table.
  class UpdateVisibilityService
    def initialize(target, visibility)
      @target = target
      @visibility = visibility
    end

    def execute
      if @visibility == Target::VISIBILITY_ARCHIVED || @visibility == Target::VISIBILITY_DRAFT
        TargetPrerequisite.transaction do
          target_prerequisites = TargetPrerequisite.where('target_id = ? OR prerequisite_target_id = ?', @target.id, @target.id)
          target_prerequisites.destroy_all if target_prerequisites.exists?
          @target.update!(safe_to_change_visibility: true, visibility: @visibility)
        end
      elsif @visibility == Target::VISIBILITY_LIVE
        TargetGroups::ArchivalService.new(@target.target_group).unarchive
        @target.update!(visibility: Target::VISIBILITY_LIVE)
      end
    end
  end
end
