module Organisations
  class StudentPolicy < ApplicationPolicy
    def show?
      return false if record.school != current_school

      return true if current_school_admin.present?

      user.admins_organisations.exists?(id: record.user.organisations)
    end

    alias submissions? show?
  end
end
