class ResourcePolicy < ApplicationPolicy
  def show?
    scope.where(id: record.id).exists?
  end

  def download?
    show?
  end

  def scope
    Pundit.policy_scope!(user, Resource.left_joins(:level))
  end

  class Scope < Scope
    def resolve
      # Public resources for everyone.
      resources = scope.where(level_id: nil, startup_id: nil)

      founder = user&.founder

      # Return public resources to founder with inactive subscription...
      return resources unless founder&.startup.present? && founder.subscription_active?

      startup = founder.startup

      return resources if startup.dropped_out?

      # ... plus resources for the startup.
      resources = resources.or(scope.where(startup: startup))

      # ... plus resources based on the startup's level.
      level = startup&.level
      resources.or(scope.where('levels.number <= ?', level.number)) if level.present?
    end
  end
end
