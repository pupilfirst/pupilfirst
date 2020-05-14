class FounderPolicy < ApplicationPolicy
  def show?
    return false if user.blank?

    # School admins can view student profiles.
    return true if user.school_admin.present?

    # Students can view their own profile.
    return true if user.founders.where(id: record).exists?

    # Coaches who review submissions from this student can view their profile.
    user.faculty.present? && user.faculty.courses.where(id: record.course).exists?
  end

  def paged_events?
    show?
  end

  def timeline_event_show?
    show?
  end

  def report?
    return false if user.blank?

    # School admins can view student profiles.
    return true if user.school_admin.present?

    # Coaches who review submissions from this student can view their profile.
    faculty = user.faculty
    faculty.present? && faculty.courses.where(id: record.course).exists?
  end
end
