module Schools
  class FoundersController < SchoolsController
    layout 'course'

    def index
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FoundersPolicy)
    end
  end
end
