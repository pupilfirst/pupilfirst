class UserPolicy < ApplicationPolicy
  def home?
    # All users can visit their home page.
    true
  end

  def edit?
    # All users can edit their profile.
    true
  end
end
