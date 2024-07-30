module Schools
  class UserPolicy < ApplicationPolicy
    def index?
      current_school_admin.present? && record == user.school
    end

    def show?
      current_school_admin.present? && record.school == user.school
    end

    alias update? show?
    alias sync_discord_roles? show?
  end
end
