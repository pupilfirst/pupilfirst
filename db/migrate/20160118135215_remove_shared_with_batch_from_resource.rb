class RemoveSharedWithBatchFromResource < ActiveRecord::Migration[4.2]
  def change
    remove_column :resources, :shared_with_batch, :integer
  end
end
