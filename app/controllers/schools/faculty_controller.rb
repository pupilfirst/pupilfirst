module Schools
  class FacultyController < SchoolsController
    layout 'school'

    # GET /school/coaches
    def school_index
      @school = authorize(current_school, policy_class: Schools::FacultyPolicy)
      @form = Schools::Coaches::CreateForm.new(Faculty.new)
    end

    # POST /school/coaches
    def create
      index

      if @form.validate(params[:schools_faculty_module_create])
        @form.save(@course)
        redirect_back(fallback_location: school_course_coaches_path(@course))
      else
        render 'index'
      end
    end

    # DELETE /school/coaches/:id
    def destroy
      coach = Faculty.find(params[:id])
      course = courses.find(params[:course_id])

      authorize([course, coach], policy_class: Schools::FacultyPolicy)

      ::Courses::UnassignReviewerService.new(course).unassign(coach)

      redirect_back(fallback_location: school_course_coaches_path(course))
    end

    def course_index
      course = courses.find(params[:course_id])
      @course = authorize(course, policy_class: Schools::FacultyPolicy)
    end
  end
end
