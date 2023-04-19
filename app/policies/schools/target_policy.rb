module Schools
  class TargetPolicy < ApplicationPolicy
    def content?
      LevelPolicy.new(@pundit_user, record.level).create?
    end

    alias details? content?
    alias versions? content?
    alias action? content?
    alias update_action? action?
  end
end
