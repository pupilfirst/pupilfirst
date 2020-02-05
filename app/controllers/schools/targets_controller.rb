module Schools
  class TargetsController < SchoolsController
    layout 'school'

    # GET /school/targets/:id/content
    def content
      target = authorize(Target.find(params[:id]), policy_class: Schools::TargetPolicy)
      @course = target.course
      render 'schools/courses/curriculum'
    end

    # GET /school/targets/:id/details
    alias details content

    # GET /school/targets/:id/versions
    alias versions content
  end
end
