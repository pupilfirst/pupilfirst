class RemoveTeamSizeFromStartup < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :team_size, :integer
  end
end
