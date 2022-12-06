module Schools
  class CalendarEventPolicy < ApplicationPolicy
    def index?
      # Can be shown to all school admins.
      user&.school_admin.present? && user.school == current_school
    end

    alias new? index?
    alias show? index?
  end
end
