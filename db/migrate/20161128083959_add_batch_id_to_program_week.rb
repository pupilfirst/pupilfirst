class AddBatchIdToProgramWeek < ActiveRecord::Migration[5.0]
  def change
    add_column :program_weeks, :batch_id, :integer
    add_index :program_weeks, :batch_id
  end
end
