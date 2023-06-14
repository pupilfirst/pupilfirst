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

    return true if record.founders.exists?(user: user)

    return true if current_school_admin.present?

    organisation = record.founders.first.user.organisation

    return false if organisation.blank?
    # check if the user is an admin of the organisation
    user.organisations.exists?(id: organisation.id)
  end
end
