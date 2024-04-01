module Targets
  # Clean-up references to the target through AssignmentPrerequisite join table.
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
      AssignmentsPrerequisiteAssignment.transaction do
        Assignments::DetachFromPrerequisitesService.new([assignment]).execute
      end
    end

    def remove_as_prerequisite
      AssignmentsPrerequisiteAssignment.where(
        prerequisite_assignment: assignment
      ).delete_all
    end

    def clear_milestone_settings
      assignment.update!(milestone: false, milestone_number: nil) if assignment
    end

    def unarchive_target_group
      TargetGroups::ArchivalService.new(@target.target_group).unarchive
    end

    def assignment
      return @assignment if defined?(@assignment)
      @assignment = @target.assignments.not_archived.first
    end
  end
end
