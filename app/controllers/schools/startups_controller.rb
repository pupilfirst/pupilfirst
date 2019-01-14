module Schools
  class StartupsController < SchoolsController
    before_action :team
    # PATCH /school/teams/:id
    def update
      form = Schools::Startups::EditForm.new(team)
      if form.validate(params[:startup])
        form.save
        redirect_back(fallback_location: school_course_students_path(team.course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # POST /school/teams/:id/remove_coach?coach_id=
    def remove_coach
      form = Schools::Startups::RemoveCoachForm.new(OpenStruct.new)
      if form.validate(params.merge(startup_id: team.id))
        form.save
        redirect_back(fallback_location: school_course_students_path(team.course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    private

    def team
      @team ||= authorize(teams.find(params[:id]), policy_class: Schools::StartupPolicy)
    end
  end
end
