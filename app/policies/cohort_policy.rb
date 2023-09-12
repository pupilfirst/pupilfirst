class CohortPolicy < ApplicationPolicy
  def show?
    return false if record.school != current_school

    return true if current_school_admin.present?

    return false if user.faculty.blank?

    user.faculty.cohorts.exists?(id: record.id)
  end

  alias students? show?
end
