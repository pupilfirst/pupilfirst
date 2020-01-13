module Schools
  class TargetPolicy < ApplicationPolicy
    def update?
      LevelPolicy.new(@pundit_user, record).create?
    end

    alias content? update?
    alias details? update?
    alias versions? update?
  end
end
