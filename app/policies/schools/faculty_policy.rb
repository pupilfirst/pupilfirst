module Schools
  class FacultyPolicy < ApplicationPolicy
    def create?
      # All school admins can add faculty.
      return true if user.school_admin.present?
    end

    def school_index?
      user.school_admin.present?
    end

    alias course_index? school_index?
    alias update? create?

    class Scope < Scope
      def resolve
        current_school.faculty
      end
    end
  end
end
