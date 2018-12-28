module Schools
  class FacultyPolicy < ApplicationPolicy
    def index?
      # All school admins can list faculty (coaches) in a course.
      true
    end

    alias create? index?

    def destroy?
      # All school admins can delete faculty (coaches) from a course.
      true
    end
  end
end
