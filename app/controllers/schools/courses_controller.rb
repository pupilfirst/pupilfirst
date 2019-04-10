module Schools
  class CoursesController < SchoolsController
    layout 'school'

    def index
      authorize current_school
    end
  end
end
