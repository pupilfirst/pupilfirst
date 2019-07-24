module Schools
  class FounderPolicy < ApplicationPolicy
    def index?
      # All school admins can list founders in a course.
      return true if user.school_admin.present?
    end

    def team_up?
      # All school admins can team up founders as the course hasn't ended.
      index? && !record.course.ended?
    end

    def update?
      # School admins can edit details of students in their open courses.
      index? && !record.course.ended?
    end

    class Scope < Scope
      def resolve
        current_school.founders
      end
    end
  end
end
