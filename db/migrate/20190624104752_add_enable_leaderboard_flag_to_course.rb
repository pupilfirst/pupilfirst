class AddEnableLeaderboardFlagToCourse < ActiveRecord::Migration[5.2]
  def up
    add_column :courses, :enable_leaderboard, :boolean, default: false
  end

  def down
    remove_column :courses, :enable_leaderboard
  end
end
