module Schools
  class FoundersController < SchoolsController
    layout 'course'

    # GET /school/courses/:course_id/students
    def index
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FounderPolicy)
    end

    # POST /school/students/team_up?founder_ids=&team_name=
    def team_up
      authorize(founders.first, policy_class: Schools::FounderPolicy)
      form = Schools::Founders::TeamUpForm.new(OpenStruct.new)

      if form.validate(params)
        startup = form.save
        presenter = Schools::Founders::IndexPresenter.new(view_context, startup.course)
        render json: { teams: presenter.teams, error: nil }
      else
        render json: { error: form.errors.full_messages.join(', ') }
      end
    end

    # POST /school/courses/:course_id/students?students[]=
    def create
      @course = authorize(courses.find(params[:course_id]), policy_class: Schools::FounderPolicy)

      form = Schools::Founders::CreateForm.new(Reform::OpenForm.new)

      if form.validate(create_params)
        form.save
        presenter = Schools::Founders::IndexPresenter.new(view_context, @course)
        render json: { teams: presenter.teams, error: nil }
      else
        render json: { error: form.errors.full_messages.join(', ') }
      end
    end

    # PATCH /school/students/:id
    def update
      student = authorize(students.find(params[:id]), policy_class: Schools::FounderPolicy)
      @course = student.course

      form = Schools::Founders::EditForm.new(student)
      if form.validate(params[:founder].merge(tags: params[:tags], coach_ids: params[:coach_ids], clear_coaches: params[:clear_coaches]))
        form.save
        presenter = Schools::Founders::IndexPresenter.new(view_context, @course)
        render json: { teams: presenter.teams, error: nil }
      else
        render json: { error: form.errors.full_messages.join(', ') }
      end
    end

    private

    def create_params
      params.permit(:course_id, tags: [], students: %i[name email])
    end

    def founders
      Founder.where(id: params[:founder_ids])
    end
  end
end
