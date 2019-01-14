class CoachDashboardPolicy < ApplicationPolicy
  def show?
    record.present? && record.in?(user&.faculty&.courses_with_dashboard)
  end
end
