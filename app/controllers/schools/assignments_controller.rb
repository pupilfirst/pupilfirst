module Schools
  class AssignmentsController < ApplicationController
    # PATCH /school/courses/:course_id/assignments/:id/update_milestone
    def update_milestone
      @milestones =
        current_school
          .courses
          .find_by(id: params[:course_id])
          .targets
          .milestones
          .order(milestone_number: :asc)

      @target = @milestones.find(params[:id])

      authorize(@target, policy_class: Schools::AssignmentPolicy)

      Schools::MilestoneSwapService.new(
        @milestones,
        @target,
        params[:direction]
      ).execute

      redirect_to assignments_school_course_path(id: params[:course_id])
    end
  end
end
