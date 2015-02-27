class AddSalaryToStartupJobs < ActiveRecord::Migration
  def change
    add_column :startup_jobs, :salary, :string
  end
end
