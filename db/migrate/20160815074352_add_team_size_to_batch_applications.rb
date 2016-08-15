class AddTeamSizeToBatchApplications < ActiveRecord::Migration
  def change
    add_column :batch_applications, :team_size, :integer
  end
end
