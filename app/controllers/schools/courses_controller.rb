module Schools
  class CoursesController < SchoolsController
    layout 'course'

    def show
      @course = courses.find(params[:id])
    end
  end
end
