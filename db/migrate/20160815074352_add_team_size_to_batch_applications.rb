class AddTeamSizeToBatchApplications < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applications, :team_size, :integer
  end
end
