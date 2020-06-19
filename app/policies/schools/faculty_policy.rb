module Schools
  class FacultyPolicy < ApplicationPolicy
    # All school admins can access faculty.
    def school_index?
      user&.school_admin.present?
    end

    def create?
      # record should belong to current school
      return false unless record.school == current_school

      school_index?
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
