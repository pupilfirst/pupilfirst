module Schools
  class CurriculaController < SchoolsController
    layout 'course'

    def show
      @course = courses.find(params[:course_id])
    end
  end
end
