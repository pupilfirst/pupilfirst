class TeamMemberPolicy < ApplicationPolicy
  def create?
    user&.founder&.startup.present?
  end

  def update?
    create? && user.founder.startup == record.startup
  end

  def destroy?
    update?
  end
end
