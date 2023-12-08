class TargetPolicy < ApplicationPolicy
  def show?
    # The curriculum page should be visible to this user.
    unless CoursePolicy.new(@pundit_user, record.course).curriculum?
      return false
    end

    # Visible only if level is accessible.
    return false unless LevelPolicy.new(@pundit_user, record.level).accessible?

    # The target must be live.
    record.live?
  end

  alias details_v2? show?

  def mark_as_read?
    return false if user.blank?

    # Has access to school
    return false unless course&.school == @current_school && student.present?

    # Student has access to the course
    return false unless !student.cohort.ended?

    true
  end

  def student
    @student ||=
      user.students.joins(:cohort).where(cohorts: { course_id: course }).first
  end

  def course
    @course ||= record&.course
  end
end
