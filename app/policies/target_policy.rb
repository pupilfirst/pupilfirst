class TargetPolicy < ApplicationPolicy
  def show?
    # PupilFirst does not have any targets.
    return false unless record.present? && record.course.school == current_school

    # Has to be a user
    return false if user.blank?

    founder = user.founders.joins(:course).where(courses: { id: record.course }).first
    # User must have a founder profile in the course
    return false if founder.blank?

    # Dropped out students cannot access course overlay.
    !founder.exited?
  end

  alias details_v2? show?
end
