class FounderPolicy < ApplicationPolicy
  def report?
    return false if user.blank?

    # School admins can view student profiles.
    return true if user.school_admin.present?

    # Coaches who review submissions from this student can view their profile.
    faculty = user.faculty
    faculty.present? && faculty.courses.where(id: record.course).exists?
  end
end
