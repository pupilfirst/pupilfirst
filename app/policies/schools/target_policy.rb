module Schools
  class TargetPolicy < ApplicationPolicy
    def create?
      # All school admins can create new target group.
      true
    end

    alias update? create?

    alias show? create?

    def destroy?
      true
    end
  end
end
