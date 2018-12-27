module Schools
  class CoursePolicy < ApplicationPolicy
    def show?
      # Can be shown to all school admins.
      true
    end

    alias update? show?

    class Scope < Scope
      def resolve
        current_school.courses
      end
    end
  end
end
