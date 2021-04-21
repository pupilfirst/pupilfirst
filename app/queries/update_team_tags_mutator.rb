class UpdateTeamTagsMutator < ApplicationQuery
  property :tags
  property :team_id, validates: { presence: true }

  def update_team_tags
    Startup.transaction do
      school = team.school

      team.update!(tag_list: tags)
      team.save!

      school.founder_tag_list << tags
      school.save!
    end
  end

  private

  def authorized?
    coach.present? && coach.courses.exists?(id: course.id)
  end

  def course
    team&.course
  end

  def team
    @team ||= Startup.find_by(id: team_id)
  end

  def coach
    @coach ||= current_user.faculty
  end
end
