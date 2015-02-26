class AddContactEmailToStartupJobs < ActiveRecord::Migration
  def change
    add_column :startup_jobs, :contact_email, :string
  end
end
