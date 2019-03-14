class AddExcludedFromLeaderboardToFounder < ActiveRecord::Migration[5.2]
  def change
    add_column :founders, :excluded_from_leaderboard, :boolean, default: false
  end
end
