module Schools
  class FacultyController < SchoolsController
    # GET /school/coaches
    def school_index
      @school = authorize(current_school, policy_class: Schools::FacultyPolicy)
      @form = Schools::Coaches::CreateForm.new(Faculty.new)
      render layout: 'school'
    end

    # POST /school/coaches
    def create
      @school = authorize(current_school, policy_class: Schools::FacultyPolicy)
      @form = Schools::Coaches::CreateForm.new(Faculty.new)

      if @form.validate(params[:faculty].merge(school_id: current_school.id))
        faculty = @form.save
        render json: { id: faculty.id, image_url: faculty.image_or_avatar_url, error: nil }
      else
        render json: { error: @form.errors.full_messages.join(', ') }
      end
    end

    def update; end

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
      render layout: 'course'
    end
  end
end
