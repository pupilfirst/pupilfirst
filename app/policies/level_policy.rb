class LevelPolicy < ApplicationPolicy
  # There is no route corresponding to this policy. It's used in multiple places to determine if a front-end user is
  # allowed to access the contents of a level.
  def accessible?
    # Level should be be accessible if its unlocked for regular students. Admins and coaches can access locked levels.
    record.unlocked? || current_school_admin.present? || CoursePolicy.new(@pundit_user, record.course).review?
  end
end
