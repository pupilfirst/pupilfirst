class AddRequestedRestartLevelToStartup < ActiveRecord::Migration[5.0]
  def change
    add_column :startups, :requested_restart_level_id, :integer
  end
end
