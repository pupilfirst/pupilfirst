class TeamsResolver < ApplicationQuery
  property :course_id
  property :level_id
  property :search

  def teams
    level_filtered = if level_id.present?
      teams_in_course.where(level_id: level_id)
    else
      teams_in_course
    end

    search_and_level_filtered = if search.present?
      level_filtered.where('users.name ILIKE ?', "%#{search}%").or(
        level_filtered.where('startups.name ILIKE ?', "%#{search}%")
      )
    else
      level_filtered
    end

    search_and_level_filtered.distinct
  end

  def authorized?
    return false if current_user.faculty.blank?

    faculty.reviewable_courses.where(id: course).exists?
  end

  def faculty
    @faculty ||= current_user.faculty
  end

  def course
    @course ||= Course.find(course_id)
  end

  def reviewable_teams
    faculty.courses.where(id: course_id).exists? ? course.startups : faculty.startups
  end

  def teams_in_course
    reviewable_teams.active.joins(founders: :user).includes(founders: [user: { avatar_attachment: :blob }])
      .select('"startups".*, LOWER(startups.name) AS startup_name').order('startup_name')
  end
end
