module Schools
  class StandingPolicy < ApplicationPolicy
    def new?
      current_school_admin.present? && user.school == current_school
    end

    alias create? new?
    alias edit? new?
    alias update? new?
    alias destroy? new?
  end
end
