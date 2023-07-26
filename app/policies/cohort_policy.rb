class CohortPolicy < ApplicationPolicy
  def show?
    return false if user.faculty.blank?

    user.faculty.cohorts.exists?(id: record.id)
  end
end
