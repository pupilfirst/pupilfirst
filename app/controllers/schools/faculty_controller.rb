module Schools
  class FacultyController < SchoolsController
    layout 'course'

    def index
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FacultyPolicy)
    end
  end
end
