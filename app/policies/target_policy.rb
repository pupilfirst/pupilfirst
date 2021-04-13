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
end
