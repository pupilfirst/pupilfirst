class TargetPolicy < ApplicationPolicy
  def download_rubric?
    user&.founder.present?
  end
end
