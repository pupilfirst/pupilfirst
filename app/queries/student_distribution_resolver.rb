class StudentDistributionResolver < ApplicationQuery
  include AuthorizeReviewer

  property :course_id
  property :coach_id
  property :coach_notes
  property :tags

  def student_distribution
    course.levels.map do |level|
      teams = TeamsResolver.filter_by_coach(teams_in_level(level), coach_id)
      teams = TeamsResolver.filter_by_coach_notes(teams, coach_notes)
      teams = TeamsResolver.filter_by_tags(teams, tags)

      team_ids = teams.select(:id).distinct(:id)
      students_in_level = Founder.where(startup: team_ids).count

      {
        id: level.id,
        number: level.number,
        students_in_level: students_in_level,
        teams_in_level: team_ids.count,
        unlocked: level.unlocked?
      }
    end
  end

  private

  def teams_in_level(level)
    level.startups.active
  end
end
