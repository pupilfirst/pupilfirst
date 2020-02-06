module Schools
  class TargetsController < SchoolsController
    layout 'school'

    # GET /school/courses/:course_id/targets/:id/content
    def content
      @course = current_school.courses.find(params[:course_id])
      authorize(@course.targets.find(params[:id]), policy_class: Schools::TargetPolicy)
      render 'schools/courses/curriculum'
    end

    # GET /school/courses/:course_id/targets/:id/details
    alias details content

    # GET /school/courses/:course_id/targets/:id/versions
    alias versions content
  end
end
