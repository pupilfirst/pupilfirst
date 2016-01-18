class AddCompositeIndexToShareStatusAndBatchId < ActiveRecord::Migration
  def change
    add_index :resources, [:share_status, :batch_id]
  end
end
