module Schools
  class CoursePolicy < ApplicationPolicy
    def index?
      # Can be shown to all school admins.
      user&.school_admin.present? && user.school == current_school
    end

    def authors?
      record.school == current_school && index?
    end

    alias attach_images? authors?
    alias delete_coach_enrollment? authors?
    alias update_coach_enrollments? authors?
    alias students? authors?
    alias inactive_students? authors?
    alias mark_teams_active? authors?
    alias exports? authors?
    alias certificates? authors?
    alias create_certificate? authors?

    def curriculum?
      return false if user.blank?

      # All school admins can manage course curriculum.
      return true if authors?

      # All course authors can manage course curriculum.
      user.course_authors.where(course: record).present?
    end

    alias evaluation_criteria? curriculum?

    class Scope < ::CoursePolicy::Scope
    end
  end
end
