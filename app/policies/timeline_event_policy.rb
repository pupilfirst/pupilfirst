class TimelineEventPolicy < ApplicationPolicy
  def review?
    return false if record.blank? || record.archived?

    return false if record.evaluation_criteria.blank?

    return false if user.faculty.blank?

    user.faculty.cohorts.exists?(id: record.students.first.cohort_id) ||
      current_school_admin.present?
  end

  def show?
    return false if record.blank? || record.archived?

    return false if record.evaluation_criteria.blank?

    return true if record.students.exists?(user: user)

    return true if current_school_admin.present?

    organisation = record.students.first.user.organisation

    return false if organisation.blank?
    # Check if the user is an admin of the organisation.
    user.organisations.exists?(id: organisation.id)
  end
end
