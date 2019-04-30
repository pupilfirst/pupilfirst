module Schools
  class CoursePolicy < ApplicationPolicy
    def show?
      # Can be shown to all school admins.
      record.in?(current_school.courses)
    end

    def update?
      # Closed courses shouldn't be updated
      !record.ended?
    end

    alias close? update?

    def delete_coach_enrollment?
      record.in?(current_school.courses) && !record.ended?
    end

    alias update_coach_enrollments? delete_coach_enrollment?

    class Scope < Scope
      def resolve
        current_school.courses
      end
    end
  end
end
