class TimelineEventPolicy < ApplicationPolicy
  def review?
    return false if record.blank? || record.archived?

    return false if record.evaluation_criteria.blank?

    return false if user.faculty.blank?

    user.faculty.cohorts.exists?(id: record.students.first.cohort_id)
  end

  def show?
    return false if record.blank? || record.archived?

    return false if record.evaluation_criteria.blank?

    return true if record.students.exists?(user: user)

    return true if current_school_admin.present?

    organisation = record.students.first.user.organisation

    return false if organisation.blank?

    user.organisations.exists?(id: record.user.organisation_id)
  end
end
