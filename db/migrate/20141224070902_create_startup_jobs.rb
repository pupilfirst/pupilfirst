class CreateStartupJobs < ActiveRecord::Migration
  def change
    create_table :startup_jobs do |t|
      t.references :startup, index: true
      t.string :title
      t.text :description
      t.integer :salary_max
      t.integer :salary_min
      t.integer :equity_max
      t.integer :equity_min
      t.integer :equity_vest
      t.integer :equity_cliff

      t.timestamps
    end
  end
end
