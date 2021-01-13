class DropStartupJobs < ActiveRecord::Migration[4.2]
  def change
    drop_table :startup_jobs
  end
end
