module Schools
  class FoundersController < SchoolsController
    include StringifyIds
    include CamelizeKeys

    # POST /school/students/team_up?founder_ids=&team_name=
    def team_up
      authorize(Founder, policy_class: Schools::FounderPolicy)
      form = Schools::Founders::TeamUpForm.new(Reform::OpenForm.new)

      response = if form.validate(params)
        startup = form.save
        presenter = Schools::Founders::IndexPresenter.new(view_context, startup.course)
        { teams: presenter.teams, students: presenter.students, error: nil }
      else
        { error: form.errors.full_messages.join(', ') }
      end

      render json: camelize_keys(stringify_ids(response))
    end

    # PATCH /school/students/:id
    def update
      student = authorize(scope.find(params[:id]), policy_class: Schools::FounderPolicy)
      @course = student.course

      form = Schools::Founders::EditForm.new(student)

      response = if form.validate(params[:founder].merge(tags: params[:tags], coach_ids: params[:coach_ids]))
        form.save
        presenter = Schools::Founders::IndexPresenter.new(view_context, @course)
        { teams: presenter.teams, students: presenter.students, error: nil }
      else
        { error: form.errors.full_messages.join(', ') }
      end

      render json: camelize_keys(stringify_ids(response))
    end

    private

    def scope
      policy_scope(Founder, policy_scope_class: Schools::FounderPolicy::Scope)
    end
  end
end
