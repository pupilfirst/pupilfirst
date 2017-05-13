class TargetPolicy < ApplicationPolicy
  def download_rubric?
    user&.founder.present?
  end

  def select2_search?
    user&.admin_user.present?
  end
end
