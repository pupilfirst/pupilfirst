module Schools
  class FoundersPolicy < ApplicationPolicy
    def index?
      # All school admins can list founders in a course.
      true
    end

    def team_up?
      # All school admins can team up founders.
      true
    end

    def create?
      # All school admins can add founders.
      true
    end
  end
end
