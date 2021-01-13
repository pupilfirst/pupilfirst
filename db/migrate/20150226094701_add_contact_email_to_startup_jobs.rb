class AddContactEmailToStartupJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_jobs, :contact_email, :string
  end
end
