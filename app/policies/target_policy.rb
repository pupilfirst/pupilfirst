class TargetPolicy < ApplicationPolicy
  def download_rubric?
    user&.founder.present? && user.founder.subscription_active?
  end

  alias prerequisite_targets? download_rubric?
  alias founder_statuses? download_rubric?
  alias startup_feedback? download_rubric?
  alias details? download_rubric?
end
