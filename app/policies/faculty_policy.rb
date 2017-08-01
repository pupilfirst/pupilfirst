class FacultyPolicy < ApplicationPolicy
  def connect?
    return false unless user&.founder&.startup_admin && user&.founder&.subscription_active?
    user.founder&.startup&.eligible_to_connect?(record)
  end
end
