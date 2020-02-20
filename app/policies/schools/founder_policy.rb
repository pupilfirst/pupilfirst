module Schools
  class FounderPolicy < ApplicationPolicy
    def index?
      # All school admins can list founders in a course.
      user&.school_admin.present?
    end

    def update?
      # School admins can edit details of students.
      index? && record.present?
    end

    # All school admins can team up founders.
    alias team_up? index?

    class Scope < Scope
      def resolve
        current_school.founders
      end
    end
  end
end
