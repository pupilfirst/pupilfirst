module Schools
  class FacultyPolicy < ApplicationPolicy
    def create?
      # All school admins can add faculty as long as the course hasn't ended.
      record.present?
    end

    def school_index?
      user.school_admins.where(school: record).present?
    end

    def update_enrollments?
      !record.ended?
    end

    alias course_index? school_index?
    alias destroy? create?
    alias update? create?

    class Scope < Scope
      def resolve
        current_school.faculty
      end
    end
  end
end
