class CourseTeamsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :level_id
  property :search
  property :tags

  def course_teams
    if search.present?
      teams_by_level_and_tag.where('users.name ILIKE ?', "%#{search}%").or(
        teams_by_level_and_tag.where('startups.name ILIKE ?', "%#{search}%")
      )
    else
      teams_by_level_and_tag
    end
  end

  private

  def course
    @course ||= Course.find(course_id)
  end

  def teams_by_tag
    teams = course.startups.active.joins(founders: :user).includes(:faculty_startup_enrollments, founders: [taggings: :tag, user: { avatar_attachment: :blob }]).distinct.order("startups.updated_at DESC")
    tags.present? ? teams.where(tags: { name: tags }) : teams
  end

  def teams_by_level_and_tag
    level_id.present? ? teams_by_tag.where(level_id: level_id) : teams_by_tag
  end
end
