module Schools
  class FacultyPolicy < ApplicationPolicy
    def index?
      # All school admins can list faculty (coaches) in a course.
      true
    end

    def create?
      # All school admins can add faculty as long as the course hasn't ended.
      !record.ended?
    end

    alias destroy? create?

    class Scope < Scope
      def resolve
        current_school.faculty
      end
    end
  end
end
