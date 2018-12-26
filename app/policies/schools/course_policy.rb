module Schools
  class CoursePolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        current_school.courses
      end
    end
  end
end
