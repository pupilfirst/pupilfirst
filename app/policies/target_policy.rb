class TargetPolicy < ApplicationPolicy
  def download_rubric?
    user&.founder.present?
  end

  alias prerequisite_targets? download_rubric?
  alias founder_statuses? download_rubric?
end
