module Schools
  class CoursePolicy < ApplicationPolicy
    def index?
      # Can be shown only to school admins.
      user.school_admin.present? && record.present?
    end

    def show?
      # Can be shown to all school admins.
      user.school_admin.present? && record.in?(current_school.courses)
    end

    def update?
      # Closed courses shouldn't be updated
      !record.ended? && show?
    end

    alias close? update?
    alias delete_coach_enrollment? update?
    alias update_coach_enrollments? delete_coach_enrollment?
    alias students? show?
    alias inactive_students? show?
    alias create_students? delete_coach_enrollment?
    alias mark_teams_active? delete_coach_enrollment?

    class Scope < Scope
      def resolve
        current_school.courses
      end
    end
  end
end
