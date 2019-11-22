module Schools
  class CoursePolicy < ApplicationPolicy
    def index?
      # Can be shown only to school admins.
      user&.school_admin.present?
    end

    def show?
      # Can be shown to all school admins.
      user&.school_admin.present?
    end

    def update?
      # Closed courses shouldn't be updated
      record.present? && !record.ended? && show?
    end

    def curriculum?
      return false if user.blank?

      # All school admins can view the curricula
      return true if user.school_admin.present?

      # All course authors can view the curricula
      user.course_authors.where(course: record).present?
    end
    alias attach_image? update?
    alias delete_coach_enrollment? update?
    alias update_coach_enrollments? delete_coach_enrollment?
    alias students? show?
    alias inactive_students? show?
    alias create_students? delete_coach_enrollment?
    alias mark_teams_active? delete_coach_enrollment?
    alias exports? show?

    class Scope < ::CoursePolicy::Scope
    end
  end
end
