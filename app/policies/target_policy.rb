class TargetPolicy < ApplicationPolicy
  def show?
    CoursePolicy.new(@pundit_user, record.course).curriculum? && record.visibility == "live"
  end

  alias details_v2? show?
end
