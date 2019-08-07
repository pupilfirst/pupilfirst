module Schools
  class FacultyController < SchoolsController
    # GET /school/coaches
    def school_index
      @school = authorize(current_school, policy_class: Schools::FacultyPolicy)
    end

    # POST /school/coaches
    def create
      @school = authorize(current_school, policy_class: Schools::FacultyPolicy)
      @form = Schools::Coaches::CreateForm.new(Faculty.new)

      if @form.validate(params[:faculty].merge(school_id: current_school.id))
        faculty = @form.save
        render json: { id: faculty.id, image_url: faculty.user.image_or_avatar_url, error: nil }
      else
        render json: { error: @form.errors.full_messages.join(', ') }
      end
    end

    def update
      @form = Schools::Coaches::UpdateForm.new(faculty)

      if @form.validate(params[:faculty].merge(school_id: current_school.id))
        faculty = @form.save
        render json: { id: faculty.id, image_url: faculty.user.image_or_avatar_url, error: nil }
      else
        render json: { error: @form.errors.full_messages.join(', ') }
      end
    end

    def course_index
      @course = policy_scope(Course, policy_scope_class: Schools::CoursePolicy::Scope).find(params[:course_id])
      authorize(current_school, policy_class: Schools::FacultyPolicy)
    end

    def faculty
      @faculty = authorize(Faculty.find(params[:id]), policy_class: Schools::FacultyPolicy)
    end
  end
end
