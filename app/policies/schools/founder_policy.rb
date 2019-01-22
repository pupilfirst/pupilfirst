module Schools
  class FounderPolicy < ApplicationPolicy
    def index?
      # All school admins can list founders in a course.
      true
    end

    def team_up?
      # All school admins can team up founders as the course hasn't ended.
      !record.course.ended?
    end

    alias create? team_up?

    def update?
      # School admins can edit details of students in their open courses.
      !record.course.ended?
    end

    class Scope < Scope
      def resolve
        current_school.founders
      end
    end
  end
end
