class TimelineEventPolicy < ApplicationPolicy
  def review?
    return false if record.blank? || record.archived?

    return false if record.evaluation_criteria.blank?

    return true if current_school_admin.present?

    return false if current_user.faculty.blank?

    current_user.faculty.cohorts.exists?(id: record.founders.first.cohort_id)
  end

  def show?
    return false if record.blank? || record.archived?

    return false if record.evaluation_criteria.blank?

    record.founders.where(user: user).present?
  end
end
