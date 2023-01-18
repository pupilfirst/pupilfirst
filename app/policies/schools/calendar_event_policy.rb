module Schools
  class CalendarEventPolicy < ApplicationPolicy
    def index?
      # Can be shown to all school admins.
      user&.school_admin.present? && user.school == current_school
    end

    alias new? index?
    alias show? index?
    alias create? index?
    alias edit? index?
    alias update? index?
    alias destroy? index?
  end
end
