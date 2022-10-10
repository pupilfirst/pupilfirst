class FounderPolicy < ApplicationPolicy
  def report?
    return false if user.blank?

    return true if current_school_admin.present?

    # Coaches who review submissions from this student can view their profile.
    faculty = user.faculty
    faculty.present? && faculty.cohorts.exists?(id: record.cohort)
  end
end
