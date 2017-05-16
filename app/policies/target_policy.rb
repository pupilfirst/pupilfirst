class TargetPolicy < ApplicationPolicy
  def download_rubric?
    user&.founder.present?
  end

  alias prerequisite_targets? download_rubric?
end
