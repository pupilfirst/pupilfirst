class TeamsResolver < ApplicationResolver
  attr_accessor :course_id
  attr_accessor :level_id

  def teams
    if level_id.present?
      teams_in_course.where(level_id: level_id)
    else
      teams_in_course
    end.includes(founders: :user)
  end

  def authorized?
    return false if current_user.faculty.blank?

    current_user.faculty.reviewable_courses.where(id: course).exists?
  end

  def course
    @course ||= Course.find(course_id)
  end

  def teams_in_course
    course.startups.active.order(:id)
  end
end
