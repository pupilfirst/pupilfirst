module Schools
  class FoundersPolicy < ApplicationPolicy
    def index?
      # All school admins can list founders in a course.
      true
    end
  end
end
