class AddLocationToStartupJob < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_jobs, :location, :string
  end
end
