class AddExpiresOnToStartupJob < ActiveRecord::Migration
  def change
    add_column :startup_jobs, :expires_on, :datetime
  end
end
