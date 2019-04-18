module Schools
  class FacultyController < SchoolsController
    # GET /school/coaches
    def school_index
      @school = authorize(current_school, policy_class: Schools::FacultyPolicy)
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

    def update
      @form = Schools::Coaches::UpdateForm.new(faculty)

      if @form.validate(params[:faculty].merge(school_id: current_school.id))
        faculty = @form.save
        render json: { id: faculty.id, image_url: faculty.image_or_avatar_url, error: nil }
      else
        render json: { error: @form.errors.full_messages.join(', ') }
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
      @course = courses.find(params[:course_id])
      authorize(current_school, policy_class: Schools::FacultyPolicy)
      render layout: 'course'
    end

    # POST /school/courses/:course_id/coaches/update_enrollments
    def update_enrollments
      course = courses.find(params[:course_id])
      @course = authorize(course, policy_class: Schools::FacultyPolicy)
      enrolled_coach_ids = params[:coach_ids]
      FacultyCourseEnrollment.transaction do
        coaches = Faculty.where(id: enrolled_coach_ids).includes(:school)
        FacultyCourseEnrollment.where(course: @course).destroy_all
        coaches.each do |coach|
          ::Courses::AssignReviewerService.new(course).assign(coach)
        end
        render json: { coach_ids: coaches.pluck(:id), error: nil }
      end
    end

    def faculty
      @faculty = authorize(Faculty.find(params[:id]), policy_class: Schools::FacultyPolicy)
    end
  end
end
