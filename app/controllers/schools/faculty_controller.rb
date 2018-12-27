module Schools
  class FacultyController < SchoolsController
    layout 'course'

    def index
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FacultyPolicy)
      @form = Schools::FacultyModule::CreateForm.new(Faculty.new)
    end

    def create
      index

      if @form.validate(params[:schools_faculty_module_create])
        @form.save(@course)
        redirect_back(fallback_location: school_course_coaches_path(@course))
      else
        render 'index'
      end
    end
  end
end
