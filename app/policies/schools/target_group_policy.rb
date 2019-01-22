module Schools
  class TargetGroupPolicy < ApplicationPolicy
    def create?
      # All school admins can create new target group.
      CoursePolicy.new(user, record.course).update?
    end

    alias update? create?

    def destroy?
      true
    end
  end
end
