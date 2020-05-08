class TeamsResolver < ApplicationQuery
  include AuthorizeReviewer

  property :course_id
  property :level_id
  property :coach_id
  property :search

  def teams
    level_filtered = if level_id.present?
      teams_in_course.where(level_id: level_id)
    else
      teams_in_course
    end

    level_and_coach_filtered = if coach_id.present?
      level_filtered.joins(:faculty_startup_enrollments)
        .where("faculty_startup_enrollments.faculty_id = ?", coach_id)
    else
      level_filtered
    end

    level_coach_and_search_filtered = if search.present?
      level_and_coach_filtered.where('users.name ILIKE ?', "%#{search}%").or(
        level_and_coach_filtered.where('startups.name ILIKE ?', "%#{search}%")
      )
    else
      level_and_coach_filtered
    end

    level_coach_and_search_filtered.distinct('startups.id')
  end

  def reviewable_teams
    course.startups
  end

  def teams_in_course
    reviewable_teams.active
      .joins({ founders: :user })
      .includes(founders: [user: { avatar_attachment: :blob }])
      .includes(:faculty)
      .select('"startups".*, LOWER(startups.name) AS startup_name').order('startup_name')
  end
end
