module Organisations
  class StudentPolicy < ApplicationPolicy
    def show?
      return false if record.school != current_school

      return true if current_school_admin.present?

      user.organisations.exists?(id: record.user.organisation_id)
    end

    alias submissions? show?
    alias standing? show?
  end
end
