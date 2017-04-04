class AddProgramStartedAtToStartup < ActiveRecord::Migration[5.0]
  def change
    add_column :startups, :program_started_at, :datetime
  end
end
