class StartupPolicy < ApplicationPolicy
  def show?
    record.level.number.positive?
  end

  def update?
    # Can't see? Can't update.
    return false unless show?

    # User's startup must be 'this' one.
    return false unless user&.founder&.startup == record

    # Founder's subscription must be active, and he must not have existed.
    user.founder.subscription_active? && !user.founder.exited?
  end

  def level_up?
    if record.level.number.positive?
      # If level 1 or above, user must be able to update to level up.
      return false unless update?
    end

    Startups::LevelUpEligibilityService.new(record, user.founder).eligible?
  end
end
