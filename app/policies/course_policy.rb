class CoursePolicy < ApplicationPolicy
  def curriculum?
    # PupilFirst does not have any courses.
    return false unless record.present? && record.school == current_school

    # Has to be a user
    return false if user.blank?

    founder = user.founders.joins(:course).where(courses: { id: record }).first
    # User must have a student profile in the course
    return false if founder.blank?

    # Dropped out students cannot access course dashboard.
    !founder.exited?
  end

  def leaderboard?
    # School admins can view the leaderboard.
    return true if current_school_admin.present?

    # Students enrolled in the current course can view the leaderboard.
    curriculum?
  end

  def apply?
    record.enable_public_signup && record.school == current_school
  end

  alias show? apply?
end
