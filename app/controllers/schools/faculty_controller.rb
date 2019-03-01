module Schools
  class FacultyController < SchoolsController
    layout 'course'

    # GET /school/courses/:course_id/coaches
    def index
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FacultyPolicy)
      @form = Schools::FacultyModule::CreateForm.new(Faculty.new)
    end

    # POST /school/courses/:course_id/coaches
    def create
      index

      if @form.validate(params[:schools_faculty_module_create])
        @form.save(@course)
        redirect_back(fallback_location: school_course_coaches_path(@course))
      else
        render 'index'
      end
    end

    # DELETE /school/courses/:course_id/coaches/:id
    def destroy
      coach = Faculty.find(params[:id])
      course = courses.find(params[:course_id])

      authorize([course, coach], policy_class: Schools::FacultyPolicy)

      ::Courses::UnassignReviewerService.new(course).unassign(coach)

      redirect_back(fallback_location: school_course_coaches_path(course))
    end
  end
end
