class TargetPolicy < ApplicationPolicy
  def show?
    # The curriculum page should be visible to this user.
    return false unless CoursePolicy.new(@pundit_user, record.course).curriculum?

    # Visible only if level is accessible.
    return false unless LevelPolicy.new(@pundit_user, record.level).accessible?

    # The target must be live.
    record.live?
  end

  alias details_v2? show?
end
