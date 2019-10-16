class CoachDashboardPolicy < ApplicationPolicy
  def show?
    CoursePolicy.new(@pundit_user, record).review?
  end

  alias timeline_events? show?
end
