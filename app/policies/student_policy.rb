class StudentPolicy < ApplicationPolicy
  def report?
    return false if user.blank?

    return false if record&.course&.school != current_school

    # School admins and coaches assigned to student's cohort can view their profile.
    current_school_admin.present? ||
      user.faculty&.cohorts&.exists?(id: record.cohort)
  end
end
