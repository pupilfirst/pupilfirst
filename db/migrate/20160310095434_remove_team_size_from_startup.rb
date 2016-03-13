class RemoveTeamSizeFromStartup < ActiveRecord::Migration
  def change
    remove_column :startups, :team_size, :integer
  end
end
