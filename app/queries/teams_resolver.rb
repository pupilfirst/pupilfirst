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
    teams = self.class.filter_by_tags(teams, tags)

    teams.distinct('startups.id')
  end

  def self.filter_by_tags(teams, tags)
    if tags.any?
      teams.tagged_with(tags)
    else
      teams
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
      .select('"startups".*, LOWER(startups.name) AS startup_name').order('startup_name')
  end
end
