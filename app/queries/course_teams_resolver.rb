class CourseTeamsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :level_id
  property :search
  property :tags
  property :sort_by
  property :sort_direction

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
    teams =
      course
        .startups
        .active
        .select('"startups".*, LOWER(startups.name) AS startup_name')
        .joins(founders: :user)
        .includes(
          :faculty_startup_enrollments,
          founders: {
            user: {
              avatar_attachment: :blob
            }
          }
        )

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
      teams
        .where(
          users: {
            id: resource_school.users.tagged_with(user_tags).select(:id)
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

  def teams_by_level_and_tag
    scope = level_id.present? ? teams_by_tag.where(level_id: level_id) : teams_by_tag
    scope.distinct.order("#{sort_by_string} #{sort_direction_string}")
  end

  def sort_direction_string
    case sort_direction
    when 'Ascending'
      'ASC'
    when 'Descending'
      'DESC'
    else
      raise "#{sort_direction} is not a valid sort direction"
    end
  end

  def sort_by_string
    case sort_by
    when 'name'
      'startup_name'
    when 'created_at'
      'created_at'
    when 'updated_at'
      'updated_at'
    else
      raise "#{sort_by} is not a valid sort criterion"
    end
  end
end
