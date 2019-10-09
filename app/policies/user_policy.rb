class UserPolicy < ApplicationPolicy
  def home?
    # current_school must be present
    return false if current_school.blank?

    # school admin can access home
    return true if current_school_admin.present?

    # coach in a school can access home
    return true if current_coach.present?

    # founder in this school can access home.
    user.founders.exists?
  end

  def edit?
    user.founders.where(exited: false).any?
  end

  alias show? edit?
end
