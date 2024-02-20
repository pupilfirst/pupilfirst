class CoursePolicy < ApplicationPolicy
  def curriculum?
    return true if record.public_preview?

    if current_school_admin.present? ||
         user.course_authors.where(course: record).present?
      return true
    end

    return true if user.faculty.present? && review?

    student = user.students.joins(:course).where(courses: { id: record }).first

    # User must have a student profile in the course
    return false if student.blank?

    # Dropped out students cannot access course dashboard.
    !student.dropped_out_at?
  end

  def leaderboard?
    # Students enrolled in the current course can view the leaderboard.
    curriculum?
  end

  def review?
    (current_school_admin.present?) || (reviewable_courses&.exists?(id: record))
  end

  def report?
    student = user.students.joins(:course).where(courses: { id: record }).first

    return false if student.blank?

    # Dropped out students cannot access report
    !student.dropped_out_at?
  end

  def show?
    true
  end

  def apply?
    record.public_signup?
  end

  alias process_application? apply?
  alias cohorts? review?
  alias calendar? curriculum?
  alias calendar_month_data? curriculum?

  class Scope < Scope
    def resolve
      current_school.courses.live
    end
  end

  private

  def reviewable_courses
    @reviewable_courses ||= current_coach&.courses&.live
  end
end
