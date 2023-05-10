module Schools
  class TargetsController < SchoolsController
    layout 'school'

    # GET /school/courses/:course_id/targets/:id/content
    def content
      @course = current_school.courses.find(params[:course_id])
      authorize(
        @course.targets.find(params[:id]),
        policy_class: Schools::TargetPolicy
      )
      render 'schools/courses/curriculum'
    end

    # GET /school/courses/:course_id/targets/:id/details
    alias details content

    # GET /school/courses/:course_id/targets/:id/versions
    alias versions content

    # GET /school/targets/:id/action
    def action
      @target = current_school.targets.find(params[:id])
      authorize(@target, policy_class: Schools::TargetPolicy)
    end

    # PATCH /school/targets/:id/update_action
    def update_action
      target = current_school.targets.find(params[:id])
      authorize(target, policy_class: Schools::TargetPolicy)

      target.action_config = params[:target][:action_config]
      target.save!

      flash[:success] = 'Action updated successfully'
      redirect_to details_school_course_target_path(target.course, target)
    end
  end
end
