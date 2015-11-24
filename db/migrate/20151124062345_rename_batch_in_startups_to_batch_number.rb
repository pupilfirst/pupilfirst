class RenameBatchInStartupsToBatchNumber < ActiveRecord::Migration
  def change
    rename_column :startups, :batch, :batch_number
  end
end
