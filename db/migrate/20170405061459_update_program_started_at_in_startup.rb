class UpdateProgramStartedAtInStartup < ActiveRecord::Migration[5.0]
  def change
    change_column :startups, :program_started_at, :date
  end
end
