module Schools
  class FoundersController < SchoolsController
    layout 'course'

    # GET /school/courses/:course_id/students
    def index
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FoundersPolicy)
    end

    # POST /school/students/team_up?founder_ids=&team_name=
    def team_up
      authorize(nil, policy_class: Schools::FoundersPolicy)

      form = Schools::Founders::TeamUpForm.new(OpenStruct.new)

      if form.validate(params)
        startup = form.save
        redirect_back(fallback_location: school_course_students_path(startup.course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    def create
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FoundersPolicy)

      form = Schools::Founders::CreateForm.new(Reform::OpenForm.new)

      if form.validate(create_params)
        form.save
        redirect_back(fallback_location: school_course_students_path(@course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    private

    def create_params
      params.permit(:course_id, :team_name, students: %i[name email])
    end
  end
end
