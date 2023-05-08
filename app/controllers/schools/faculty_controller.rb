module Schools
  class FacultyController < SchoolsController
    # GET /school/coaches
    def school_index
      @school = authorize(current_school, policy_class: Schools::FacultyPolicy)
      @status = params[:status] || "active"
    end

    # POST /school/coaches
    def create
      @school = authorize(current_school, policy_class: Schools::FacultyPolicy)
      @form = Schools::Coaches::CreateForm.new(Faculty.new)

      if @form.validate(
           transformed_params(params).merge(school_id: current_school.id)
         )
        faculty = @form.save
        render json: {
                 id: faculty.id.to_s,
                 image_url: faculty.user.image_or_avatar_url,
                 error: nil
               }
      else
        render json: { error: @form.errors.full_messages.join(", ") }
      end
    end

    def update
      @form = Schools::Coaches::UpdateForm.new(faculty)

      if @form.validate(
           transformed_params(params).merge(school_id: current_school.id)
         )
        faculty = @form.save
        render json: {
                 id: faculty.id.to_s,
                 image_url: faculty.user.image_or_avatar_url,
                 error: nil
               }
      else
        render json: { error: @form.errors.full_messages.join(", ") }
      end
    end

    def course_index
      @course =
        policy_scope(
          Course,
          policy_scope_class: Schools::CoursePolicy::Scope
        ).find(params[:course_id])
      authorize(current_school, policy_class: Schools::FacultyPolicy)
    end

    def faculty
      @faculty =
        authorize(
          Faculty.find(params[:id]),
          policy_class: Schools::FacultyPolicy
        )
    end

    # work around for mismatch of archived_at key
    def transformed_params(params)
      params[:faculty].transform_keys do |key|
        key == "archived" ? "archived_at" : key # map archived to archived_at
      end
    end
  end
end
