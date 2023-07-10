module Schools
  class AssignmentsController < ApplicationController
    # PATCH /school/assignments/:id/update_milestone_number
    def update_milestone_number
      @target = Target.find(params[:id])
      @page_no = params[:page] || 1

      authorize(@target, policy_class: Schools::AssignmentPolicy)

      Schools::MilestoneSortService.new(@target, params[:direction]).execute

      redirect_to assignments_school_course_path(
                    id: @target.course.id,
                    page: @page_no
                  )
    end
  end
end
