class StartupPolicy < ApplicationPolicy
  def show?
    record.level.number.positive?
  end

  def edit?
    show? && user&.founder&.startup == record && user&.founder&.subscription_active?
  end

  def update?
    edit?
  end

  def level_up?
    Startups::LevelUpEligibilityService.new(record, user.founder).eligible?
  end
end
