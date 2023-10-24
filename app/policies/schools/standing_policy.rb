module Schools
  class StandingPolicy < ApplicationPolicy
    def new?
      user&.school_admin.present? && user.school == current_school
    end

    alias create? new?
    alias edit? new?
    alias update? new?
    alias destroy? new?
  end
end
