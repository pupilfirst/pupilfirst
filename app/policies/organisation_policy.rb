class OrganisationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.school_admin.present?
        user.school.organisations
      else
        user.admins_organisations
      end
    end
  end
end
