module Coaches
  class DashboardPolicy < ApplicationPolicy
    def index?
      user.faculty&.startups.present? || user.faculty&.courses.present?
    end
  end
end
