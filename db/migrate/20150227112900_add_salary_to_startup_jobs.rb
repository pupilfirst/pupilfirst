class AddSalaryToStartupJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_jobs, :salary, :string
  end
end
