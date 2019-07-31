module Schools
  class CommunityPolicy < ApplicationPolicy
    def index?
      # Can be shown to all school admins.
      user&.school_admin.present?
    end
  end
end
