module Schools
  class FacultyPolicy < ApplicationPolicy
    def index?
      # All school admins can list faculty (coaches) in a course.
      true
    end
  end
end
