class CohortPolicy < ApplicationPolicy
  def show?
    return true if current_school_admin.present?

    return false if user.faculty.blank?

    user.faculty.cohorts.exists?(id: record.id)
  end

  alias students? show?
end
