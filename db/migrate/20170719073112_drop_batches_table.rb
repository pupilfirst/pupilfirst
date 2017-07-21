class DropBatchesTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :batches
  end
end
