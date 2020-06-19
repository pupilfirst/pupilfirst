module Schools
  class CoursePolicy < ApplicationPolicy
    def index?
      # Can be shown to all school admins.
      user&.school_admin.present?
    end

    def show?
      # record should belong to current school
      return false unless record.school == current_school

      index?
    end

    def curriculum?
      return false if user.blank?

      # All school admins can view the curricula
      return true if show?

      # All course authors can view the curricula
      user.course_authors.where(course: record).present?
    end

    def attach_images?
      show? && record.present?
    end

    alias delete_coach_enrollment? attach_images?
    alias update_coach_enrollments? attach_images?
    alias students? show?
    alias inactive_students? show?
    alias create_students? attach_images?
    alias mark_teams_active? attach_images?
    alias exports? show?
    alias authors? show?
    alias evaluation_criteria? curriculum?

    class Scope < ::CoursePolicy::Scope
    end
  end
end
