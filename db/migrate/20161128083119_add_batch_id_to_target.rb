class AddBatchIdToTarget < ActiveRecord::Migration[5.0]
  def change
    add_column :targets, :batch_id, :integer
    add_index :targets, :batch_id
  end
end
