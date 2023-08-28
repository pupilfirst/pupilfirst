module Schools
  class AssignmentsController < ApplicationController
    # PATCH /school/assignments/:id/update_milestone_number
    def update_milestone_number
      target =
        authorize(
          Target.find(params[:id]),
          policy_class: Schools::AssignmentPolicy
        )

      Schools::MilestoneSortService.new(target, params[:direction]).execute

      redirect_to assignments_school_course_path(
                    id: target.course.id,
                    page: (params[:page] || 1)
                  )
    end
  end
end
