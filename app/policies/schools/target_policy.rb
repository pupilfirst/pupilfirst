module Schools
  class TargetPolicy < ApplicationPolicy
    def create?
      # Is this user allowed to create a target in the requested target group.
      CoursePolicy.new(user, record.course).update?
    end

    alias update? create?

    def destroy?
      true
    end
  end
end
