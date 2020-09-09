module Schools
  class FacultyPolicy < ApplicationPolicy
    # All school admins can access faculty.
    def school_index?
      user&.school_admin.present?
    end

    def update?
      # record should belong to current school
      return false unless record.school == current_school

      school_index?
    end

    alias create? school_index?
    alias course_index? school_index?

    class Scope < Scope
      def resolve
        current_school.faculty
      end
    end
  end
end
