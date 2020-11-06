class CoursePolicy < ApplicationPolicy
  def curriculum?
    return true if current_school_admin.present? || user.course_authors.where(course: record).present?

    return true if user.faculty.present? && review?

    founder = user.founders.joins(:course).where(courses: { id: record }).first
    # User must have a student profile in the course
    return false if founder.blank?

    # Dropped out students cannot access course dashboard.
    !founder.dropped_out?
  end

  def leaderboard?
    # Students enrolled in the current course can view the leaderboard.
    curriculum?
  end

  def review?
    record.present? && reviewable_courses.present? && reviewable_courses.exists?(id: record)
  end

  def report?
    return false if record.blank?

    founder = user.founders.joins(:course).where(courses: { id: record }).first

    return false if founder.blank?

    # Dropped out students cannot access report
    !founder.dropped_out?
  end

  def show?
    true
  end

  def apply?
    record&.school == current_school && record.public_signup?
  end

  alias students? review?

  class Scope < Scope
    def resolve
      current_school.courses
    end
  end

  private

  def reviewable_courses
    @reviewable_courses ||= current_coach&.courses
  end
end
