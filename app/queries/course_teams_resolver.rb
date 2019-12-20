class CourseTeamsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :level_id
  property :search
  property :tags

  def course_teams
    teams
  end

  def filtered_teams
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

    tags.present? ? search_and_level_filtered.tagged_with(tags, any: true) : search_and_level_filtered
  end

  def course
    @course ||= Course.find(course_id)
  end

  def teams_in_course
    course.startups.active.joins(founders: :user).includes(:faculty_startup_enrollments, founders: [taggings: :tag, user: { avatar_attachment: :blob }]).order('startups.name')
  end

  def teams
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

  def founder_tags
    @founder_tags ||= current_school.founder_tag_list
  end
end
