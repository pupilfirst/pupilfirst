class CohortPolicy < ApplicationPolicy
  def show?
    return false if user.faculty.blank? && current_school_admin.blank?

    current_school_admin.present? || user.faculty.cohorts.exists?(id: record.id)
  end

  alias students? show?
end
