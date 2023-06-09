class Courses::CohortPolicy < ApplicationPolicy
  def show?
    return false if user.faculty.blank?

    user.faculty.courses.exists?(id: record.course_id)
  end

  alias students? show?
end
