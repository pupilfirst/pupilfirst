module Schools
  class TargetGroupPolicy < ApplicationPolicy
    def create?
      LevelPolicy.new(@pundit_user, record).create?
    end

    alias update? create?
  end
end
