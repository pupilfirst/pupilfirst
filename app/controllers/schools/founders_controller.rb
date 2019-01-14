module Schools
  class FoundersController < SchoolsController
    layout 'course'

    # GET /school/courses/:course_id/students
    def index
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FounderPolicy)
    end

    # POST /school/students/team_up?founder_ids=&team_name=
    def team_up
      authorize(nil, policy_class: Schools::FounderPolicy)

      form = Schools::Founders::TeamUpForm.new(OpenStruct.new)

      if form.validate(params)
        startup = form.save
        redirect_back(fallback_location: school_course_students_path(startup.course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # POST /school/courses/:course_id/students?team_name=&students[]=
    def create
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FounderPolicy)

      form = Schools::Founders::CreateForm.new(Reform::OpenForm.new)

      if form.validate(create_params)
        form.save
        redirect_back(fallback_location: school_course_students_path(@course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # PATCH /school/students/:id
    def update
      student = authorize(students.find(params[:id]), policy_class: Schools::FounderPolicy)

      form = Schools::Founders::EditForm.new(student)
      if form.validate(params[:founder])
        form.save
        redirect_back(fallback_location: school_course_students_path(student.course))
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
