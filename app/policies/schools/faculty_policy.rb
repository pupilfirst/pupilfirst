module Schools
  class FacultyPolicy < ApplicationPolicy
    # All school admins can access faculty.
    def school_index?
      user&.school_admin.present?
    end

    alias create? school_index?
    alias course_index? school_index?
    alias update? school_index?

    class Scope < Scope
      def resolve
        current_school.faculty
      end
    end
  end
end
