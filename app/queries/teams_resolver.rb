class TeamsResolver < ApplicationQuery
  attr_accessor :course_id
  attr_accessor :level_id
  attr_accessor :search

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

    current_user.faculty.reviewable_courses.where(id: course).exists?
  end

  def course
    @course ||= Course.find(course_id)
  end

  def teams_in_course
    course.startups.active.joins(founders: :user).includes(founders: [user: { avatar_attachment: :blob }]).order('startups.name')
  end
end
