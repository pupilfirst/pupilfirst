class RenameBatchInStartupsToBatchNumber < ActiveRecord::Migration[4.2]
  def change
    rename_column :startups, :batch, :batch_number
  end
end
