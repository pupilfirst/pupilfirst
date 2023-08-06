class StudentPolicy < ApplicationPolicy
  def report?
    return false if user.blank?

    # Coaches who review submissions from this student can view their profile.
    faculty = user.faculty
    current_school_admin.present? ||
      (faculty.present? && faculty.cohorts.exists?(id: record.cohort))
  end
end
