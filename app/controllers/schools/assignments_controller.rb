module Schools
  class AssignmentsController < ApplicationController
    # /school/courses/:course_id/assignments/:id
    def update
      @milestones =
        current_school
          .courses
          .find_by(id: params[:course_id])
          .targets
          .milestones
          .order(milestone_number: :asc)

      authorize(@milestones, policy_class: Schools::AssignmentPolicy)

      @target = @milestones.find(params[:id])

      swap(params[:direction])

      redirect_to assignments_school_course_path(id: params[:course_id])
    end

    private

    def swap(direction)
      index = @milestones.index(@target)

      if (index < 1 && direction == "up") ||
           (index >= @milestones.size - 1 && direction == "down")
        return
      end

      target_2 = @milestones[direction == "up" ? index - 1 : index + 1]

      Target.transaction do
        number = @target.milestone_number
        @target.update!(milestone_number: target_2.milestone_number)
        target_2.update!(milestone_number: number)
      end
    end
  end
end
