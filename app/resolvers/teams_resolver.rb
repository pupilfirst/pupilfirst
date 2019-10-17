class TeamsResolver < ApplicationResolver
  attr_accessor :course_id
  attr_accessor :level_id

  def teams
    course.startups.includes(founders: :user)
  end

  def authorized?
    return false if current_user.faculty.blank?

    current_user.faculty.reviewable_courses.where(id: course).exists?
  end

  def course
    @course ||= Course.find(course_id)
  end
end
