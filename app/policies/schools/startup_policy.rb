module Schools
  class StartupPolicy < ApplicationPolicy
    def team_update?
      # School admins can edit details of teams in their open courses.
      !record.course.ended?
    end

    class Scope < Scope
      def resolve
        current_school.startups
      end
    end
  end
end
