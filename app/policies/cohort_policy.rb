class CohortPolicy < ApplicationPolicy
  def show?
    return false if user.faculty.blank?

    user.faculty.cohorts.exists?(id: record.id) || current_school_admin.present?
  end

  alias students? show?
end
