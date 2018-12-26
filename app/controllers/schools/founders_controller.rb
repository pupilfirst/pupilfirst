module Schools
  class FoundersController < SchoolsController
    layout 'course'

    def index
      @course = courses.find(params[:course_id])
    end
  end
end
