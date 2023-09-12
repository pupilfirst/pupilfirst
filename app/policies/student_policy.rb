class StudentPolicy < ApplicationPolicy
  def report?
    return false if user.blank?

    # School admins and coaches assigned to student's cohort can view their profile.
    faculty = user.faculty
    current_school_admin.present? ||
      (faculty.present? && faculty.cohorts.exists?(id: record.cohort))
  end
end
