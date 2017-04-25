class ResourcePolicy < ApplicationPolicy
  def download?
    show?
  end

  def scope
    Pundit.policy_scope!(user, Resource.left_joins(:level))
  end

  class Scope < Scope
    def resolve
      # public resources for everyone
      resources = scope.where(level_id: nil, startup_id: nil)

      # + resources for the startup
      startup = user&.founder&.startup
      resources = resources.or(scope.where(startup: startup)) if startup.present?

      # + resources based on the startup's maximum level
      maximum_level = startup&.maximum_level
      resources = resources.or(scope.where('levels.number <= ?', maximum_level.number)) if maximum_level.present?

      resources
    end
  end
end
