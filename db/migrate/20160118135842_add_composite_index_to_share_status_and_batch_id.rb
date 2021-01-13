class AddCompositeIndexToShareStatusAndBatchId < ActiveRecord::Migration[4.2]
  def change
    add_index :resources, [:share_status, :batch_id]
  end
end
