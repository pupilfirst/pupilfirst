class CoursePolicy < ApplicationPolicy
  def show?
    record.present? && record == current_founder&.course
  end

  def leaderboard?
    # School admins can view the leaderboard.
    return true if current_school_admin.present?

    # Students enrolled in the current course can view the leaderboard.
    show?
  end
end
