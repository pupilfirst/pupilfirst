class AddExpiresOnToStartupJob < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_jobs, :expires_on, :datetime
  end
end
