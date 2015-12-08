class DropStartupJobs < ActiveRecord::Migration
  def change
    drop_table :startup_jobs
  end
end
