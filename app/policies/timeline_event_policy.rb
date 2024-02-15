class TimelineEventPolicy < ApplicationPolicy
  def review?
    return false if record&.course&.school != current_school

    return false if record.archived?

    return false if record.evaluation_criteria.blank?

    return true if current_school_admin.present?

    user.faculty&.cohorts&.exists?(id: record.students.first.cohort_id)
  end

  def show?
    return false if record&.course&.school != current_school

    return false if record.archived?

    return true if record.students.exists?(user: user)

    return true if current_school_admin.present?

    organisation = record.students.first.user.organisation

    return false if organisation.blank?
    # Check if the user is an admin of the organisation.
    user.organisations.exists?(id: organisation.id)
  end
end
