module Schools
  class StartupPolicy < ApplicationPolicy
    def update?
      # School admins can edit details of teams in their open courses.
      !record.course.ended?
    end

    alias remove_coach? update?

    class Scope < Scope
      def resolve
        current_school.startups
      end
    end
  end
end
