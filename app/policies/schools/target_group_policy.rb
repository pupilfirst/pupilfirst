module Schools
  class TargetGroupPolicy < ApplicationPolicy
    def create?
      # All school admins can create new target group.
      true
    end

    alias update? create?

    def destroy?
      true
    end
  end
end
