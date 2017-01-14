class RemoveBatchIdFromTarget < ActiveRecord::Migration[5.0]
  def change
    remove_column :targets, :batch_id, :integer
  end
end
