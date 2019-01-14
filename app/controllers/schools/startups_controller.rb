module Schools
  class StartupsController < SchoolsController
    # PATCH /school/teams/:id
    def update
      team = authorize(teams.find(params[:id]), policy_class: Schools::StartupPolicy)

      form = Schools::Founders::TeamEditForm.new(team)
      if form.validate(params[:startup])
        form.save
        redirect_back(fallback_location: school_course_students_path(team.course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end
  end
end
