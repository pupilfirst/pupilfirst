class StartupPolicy < ApplicationPolicy
  def show?
    record.level.number.positive?
  end

  def update?
    show? && user&.founder&.startup == record
  end
end
