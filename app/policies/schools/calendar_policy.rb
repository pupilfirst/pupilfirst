module Schools
  class CalendarPolicy < ApplicationPolicy
    def new?
      # Can be shown to all school admins.
      user&.school_admin.present? && user.school == current_school
    end

    alias create? new?
    alias edit? new?
    alias update? new?
  end
end
