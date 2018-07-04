class AboutPolicy < ApplicationPolicy
  def leaderboard?
    # Leaderboard has been disabled, for the time being.
    false
  end
end
