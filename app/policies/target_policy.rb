class TargetPolicy < ApplicationPolicy
  def show?
    CoursePolicy.new(@pundit_user, record.course).curriculum? && record.live?
  end

  alias details_v2? show?
end
