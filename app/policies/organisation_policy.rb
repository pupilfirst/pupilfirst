class OrganisationPolicy < ApplicationPolicy
  def index
    CommunityPolicy.new(@pundit_user, record.topic.community).show?
  end

  class Scope < Scope
    def resolve
      user.organisations
    end
  end
end
