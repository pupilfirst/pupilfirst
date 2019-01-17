class CoachDashboardPolicy < ApplicationPolicy
  def show?
    record.present? && courses_with_dashboard.present? && record.in?(courses_with_dashboard)
  end

  alias timeline_events? show?

  private

  def courses_with_dashboard
    @courses_with_dashboard ||= user&.faculty&.courses_with_dashboard
  end
end
