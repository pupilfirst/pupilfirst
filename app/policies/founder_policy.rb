class FounderPolicy < ApplicationPolicy
  def report?
    return false if user.blank?

    # Coaches who review submissions from this student can view their profile.
    faculty = user.faculty
    faculty.present? && faculty.courses.where(id: record.course).exists?
  end
end
