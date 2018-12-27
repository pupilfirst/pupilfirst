module Schools
  class CurriculaController < SchoolsController
    layout 'course'

    def show
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::CurriculaPolicy)
    end
  end
end
