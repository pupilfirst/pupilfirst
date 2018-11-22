class FacultyPolicy < ApplicationPolicy
  def connect?
    return false unless current_founder&.team_lead? && current_founder&.subscription_active?

    current_founder&.startup&.eligible_to_connect?(record)
  end
end
