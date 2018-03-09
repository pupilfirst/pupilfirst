class TargetPolicy < ApplicationPolicy
  def download_rubric?
    user&.founder.present? && (user.founder.subscription_active? || user.founder.startup&.level_zero?)
  end

  alias prerequisite_targets? download_rubric?
  alias startup_feedback? download_rubric?
  alias details? download_rubric?
end
