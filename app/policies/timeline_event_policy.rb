class TimelineEventPolicy < ApplicationPolicy
  def review?
    return false if record.blank? || record.archived?

    return false if record.evaluation_criteria.blank?

    return false if user.faculty.blank?

    user.faculty.cohorts.exists?(id: record.founders.first.cohort_id)
  end

  def show?
    return false if record.blank? || record.archived?

    return false if record.evaluation_criteria.blank?

    record.founders.where(user: user).present?
  end
end
