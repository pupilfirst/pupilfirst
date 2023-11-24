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

    return false if record.evaluation_criteria.blank?

    return true if record.students.exists?(user: user)

    return true if current_school_admin.present?

    organisations = record.students.first.user.organisations

    return false if organisations.blank?
    # Check if the user is an admin of the organisation.
    user.admins_organisations.exists?(id: organisations.pluck(:id))
  end
end
