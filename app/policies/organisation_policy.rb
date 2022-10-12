class OrganisationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.organisations
    end
  end
end
