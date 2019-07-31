module Schools
  class FounderPolicy < ApplicationPolicy
    def index?
      # All school admins can list founders in a course.
      user&.school_admin.present?
    end

    def update?
      # School admins can edit details of students in their open courses.
      index? && record.present? && !record.course.ended?
    end

    # All school admins can team up founders if the course hasn't ended.
    alias team_up? update?

    class Scope < Scope
      def resolve
        current_school.founders
      end
    end
  end
end
