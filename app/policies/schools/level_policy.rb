module Schools
  class LevelPolicy < ApplicationPolicy
    def create?
      # All school admins can create new criteria.
      true
    end

    alias update? create?

    def destroy?
      true
    end
  end
end
