module Schools
  class FoundersController < SchoolsController
    # POST /school/students/team_up?founder_ids=&team_name=
    def team_up
      authorize(Founder, policy_class: Schools::FounderPolicy)
      form = Schools::Founders::TeamUpForm.new(Reform::OpenForm.new)

      response = if form.validate(params)
        form.save
        { error: nil }
      else
        { error: form.errors.full_messages.join(', ') }
      end

      render json: response
    end

    # PATCH /school/students/:id
    def update
      student = authorize(scope.find(params[:id]), policy_class: Schools::FounderPolicy)
      @course = student.course

      form = Schools::Founders::EditForm.new(student)

      response = if form.validate(params[:founder].merge(tags: params[:tags], access_ends_at: params[:access_ends_at], coach_ids: params[:coach_ids]))
        form.save
        { error: nil }
      else
        { error: form.errors.full_messages.join(', ') }
      end

      render json: response
    end

    private

    def scope
      policy_scope(Founder, policy_scope_class: Schools::FounderPolicy::Scope)
    end
  end
end
