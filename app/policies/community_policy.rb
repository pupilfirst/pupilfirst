class CommunityPolicy < ApplicationPolicy
  def show?
    scope.where(id: record.id).exists?
  end

  class Scope < Scope
    def resolve
      # Pupilfirst doesn't have community.
      return scope.none if current_school.blank?

      return scope.none unless [current_founder, current_coach].any?

      scope.where(school: current_school)
    end
  end
end
