module Schools
  class FounderPolicy < ApplicationPolicy
    def index?
      # All school admins can list founders in a course.
      user&.school_admin.present?
    end

    def update?
      # record should belong to current school
      return false unless record&.school == current_school
      # School admins can edit details of students.
      index?
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
