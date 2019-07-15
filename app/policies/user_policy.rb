class UserPolicy < ApplicationPolicy
  def home?
    # current_school must be present
    return false if current_school.blank?

    # coach in a school can access home
    return true if current_coach.present?

    # founder in this school can access home.
    user.founders.exists?
  end
end
