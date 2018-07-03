module Coaches
  class DashboardPolicy < ApplicationPolicy
    def index?
      user.faculty&.startups.present?
    end
  end
end
