class CoursePolicy < ApplicationPolicy
  def curriculum?
    return true if current_school_admin.present?

    founder = user.founders.joins(:course).where(courses: { id: record }).first

    # Dropped out students cannot access course dashboard. # User must have a student profile in the course
    founder&.exited? || review?
  end

  def leaderboard?
    # Students enrolled in the current course can view the leaderboard.
    curriculum?
  end

  def review?
    record.present? && courses_with_dashboard.present? && record.in?(courses_with_dashboard)
  end

  def apply?
    record&.school == current_school && record.public_signup?
  end

  alias show? apply?

  class Scope < Scope
    def resolve
      current_school.courses
    end
  end

  private

  def courses_with_dashboard
    @courses_with_dashboard ||= current_coach&.courses_with_dashboard
  end
end
