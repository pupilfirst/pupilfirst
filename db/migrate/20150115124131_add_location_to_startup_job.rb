class AddLocationToStartupJob < ActiveRecord::Migration
  def change
    add_column :startup_jobs, :location, :string
  end
end
