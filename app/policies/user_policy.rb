class UserPolicy < ApplicationPolicy
  def dashboard?
    # All users can visit their dashboard page.
    true
  end

  def edit?
    # All users can edit their profile.
    true
  end

  def discord_account_required?
    # All users can visit the Discord account requirement page.
    true
  end

  alias standing? edit?
end
