module Schools
  class UserPolicy < ApplicationPolicy
    def show?
      current_school_admin.present? && record.school == user.school
    end

    alias update? show?
  end
end
