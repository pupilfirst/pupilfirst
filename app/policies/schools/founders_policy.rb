module Schools
  class FoundersPolicy < ApplicationPolicy
    def index?
      # All school admins can list founders in a course.
      true
    end

    def team_up?
      # All school admins can team up founders as the course hasn't ended.
      !record.ended?
    end

    alias create? team_up?
  end
end
