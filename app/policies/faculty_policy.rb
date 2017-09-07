class FacultyPolicy < ApplicationPolicy
  def connect?
    return false unless user&.founder&.team_lead? && user&.founder&.subscription_active?
    user.founder&.startup&.eligible_to_connect?(record)
  end
end
