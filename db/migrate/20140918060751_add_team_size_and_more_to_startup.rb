class AddTeamSizeAndMoreToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :team_size, :integer
    add_column :startups, :women_employees, :integer
  end
end
