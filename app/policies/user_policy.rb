class UserPolicy < ApplicationPolicy
  def home?
    true
  end

  def edit?
    user.founders.where(exited: false).any?
  end

  alias show? edit?
end
