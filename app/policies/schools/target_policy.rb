module Schools
  class TargetPolicy < ApplicationPolicy
    def create?
      LevelPolicy.new(@pundit_user, record).create?
    end

    alias update? create?
  end
end
