class UserPolicy < ApplicationPolicy
  def dashboard?
    # All users can visit their dashboard page.
    true
  end

  def edit?
    # All users can edit their profile.
    true
  end
end
