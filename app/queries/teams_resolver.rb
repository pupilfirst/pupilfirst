class TeamsResolver < ApplicationQuery
  include AuthorizeReviewer

  property :course_id
  property :coach_notes
  property :level_id
  property :coach_id
  property :search
  property :tags

  def teams
    # A sad side-effect of Ruby not having function piping. Is there a cleaner alternative?
    teams = filter_by_level(teams_in_course)
    teams = self.class.filter_by_coach(teams, coach_id)
    teams = filter_by_search(teams)
    teams = self.class.filter_by_coach_notes(teams, coach_notes)
    teams = self.class.filter_by_tags(course, teams, tags)

    teams.distinct('startups.id')
      .select('"startups".*, LOWER(startups.name) AS startup_name').order('startup_name')
  end

  def self.filter_by_tags(course, teams, tags)
    return teams if tags.blank?

    user_tags =
      tags.intersection(
          course
            .users
            .joins(taggings: :tag)
            .distinct('tags.name')
            .pluck('tags.name')
        )

    team_tags =
      tags.intersection(
        course
          .startups
          .joins(taggings: :tag)
          .distinct('tags.name')
          .pluck('tags.name')
      )

    intersect_teams = user_tags.present? && team_tags.present?

    teams_with_user_tags =
      teams.joins({ founders: :user })
        .where(
          users: {
            id: course.school.users.tagged_with(user_tags).select(:id)
          }
        )
        .pluck(:id)

    teams_with_tags = teams.tagged_with(team_tags).pluck(:id)

    if intersect_teams
      teams.where(id: teams_with_user_tags.intersection(teams_with_tags))
    else
      teams.where(id: teams_with_user_tags + teams_with_tags)
    end
  end

  def self.filter_by_coach_notes(teams, coach_notes)
    case coach_notes
    when 'WithCoachNotes'
      teams.joins(founders: :coach_notes)
    when 'WithoutCoachNotes'
      teams.left_joins(founders: :coach_notes).where(coach_notes: { id: nil })
    else
      teams
    end
  end

  def self.filter_by_coach(teams, coach_id)
    if coach_id.present?
      teams.joins(:faculty_startup_enrollments)
        .where(faculty_startup_enrollments: { faculty_id: coach_id })
    else
      teams
    end
  end

  private

  def filter_by_level(teams)
    if level_id.present?
      teams.where(level_id: level_id)
    else
      teams
    end
  end

  def filter_by_search(teams)
    if search.present?
      teams.where('users.name ILIKE ?', "%#{search}%")
        .or(teams.where('users.email ILIKE ?', "%#{search}%"))
        .or(teams.where('startups.name ILIKE ?', "%#{search}%"))
    else
      teams
    end
  end

  def teams_in_course
    course.startups.active
      .joins({ founders: :user })
      .includes(founders: [user: { avatar_attachment: :blob }])
      .includes(:faculty)
  end
end
