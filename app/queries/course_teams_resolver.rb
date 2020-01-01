class CourseTeamsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :level_id
  property :search
  property :tags

  def course_teams
    filtered_teams.map do |team|
      {
        id: team.id,
        name: team.name,
        coach_ids: team.faculty_startup_enrollments.pluck(:faculty_id),
        level_id: team.level_id,
        access_ends_at: team.access_ends_at,
        students: students(team)
      }
    end
  end

  private

  def students(team)
    team.founders.map do |student|
      student_props = {
        id: student.id,
        name: student.user.name,
        email: student.user.email,
        team_id: student.startup_id,
        tags: student.taggings.map { |tagging| tagging.tag.name } & founder_tags,
        excluded_from_leaderboard: student.excluded_from_leaderboard,
        title: student.user.title,
        affiliation: student.user.affiliation
      }

      if student.user.avatar.attached?
        student_props[:avatar_url] = Rails.application.routes.url_helpers.rails_representation_path(student.user.avatar_variant(:thumb), only_path: true)
      end

      student_props
    end
  end

  def course
    @course ||= Course.find(course_id)
  end

  def founder_tags
    @founder_tags ||= current_school.founder_tag_list
  end

  def teams_by_tag
    teams = course.startups.active.joins(founders: :user).includes(:faculty_startup_enrollments, founders: [taggings: :tag, user: { avatar_attachment: :blob }]).distinct.order("updated_at DESC")
    tags.present? ? teams.where(tags: { name: tags }) : teams
  end

  def teams_by_level_and_tag
    level_id.present? ? teams_by_tag.where(level_id: level_id) : teams_by_tag
  end

  def filtered_teams
    if search.present?
      teams_by_level_and_tag.where('users.name ILIKE ?', "%#{search}%").or(
        teams_by_level_and_tag.where('startups.name ILIKE ?', "%#{search}%")
      )
    else
      teams_by_level_and_tag
    end
  end
end
