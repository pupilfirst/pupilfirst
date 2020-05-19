class CourseTeamsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :level_id
  property :search
  property :tags
  property :sort_by

  def course_teams
    if search.present?
      teams_by_level_and_tag.where('users.name ILIKE ?', "%#{search}%").or(
        teams_by_level_and_tag.where('startups.name ILIKE ?', "%#{search}%")
      ).or(teams_by_level_and_tag.where('users.email ILIKE ?', "%#{search}%"))
    else
      teams_by_level_and_tag
    end
  end

  private

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find(course_id)
  end

  def teams_by_tag
    teams = course.startups.active
      .select('"startups".*, LOWER(startups.name) AS startup_name')
      .joins(founders: :user)
      .includes(:faculty_startup_enrollments, founders: { user: { avatar_attachment: :blob } })
      .distinct.order(sort_by_string)

    tags.present? ? teams.joins(founders: [taggings: :tag]).where(tags: { name: tags }) : teams.includes(founders: [taggings: :tag])
  end

  def teams_by_level_and_tag
    level_id.present? ? teams_by_tag.where(level_id: level_id) : teams_by_tag
  end

  def sort_by_string
    case sort_by
    when 'name'
      'startup_name'
    when 'created_at'
      'created_at DESC'
    when 'updated_at'
      'updated_at DESC'
    else
      'startup_name'
    end
  end
end
