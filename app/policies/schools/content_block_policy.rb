module Schools
  class ContentBlockPolicy < ApplicationPolicy
    def create?
      LevelPolicy.new(@pundit_user, record).create?
    end
  end
end
