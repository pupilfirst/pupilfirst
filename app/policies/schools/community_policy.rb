module Schools
  class CommunityPolicy < ApplicationPolicy
    def index?
      # Can be shown to all school admins.
      user.school_admins.where(school: record).present?
    end
  end
end
