class RemoveSharedWithBatchFromResource < ActiveRecord::Migration
  def change
    remove_column :resources, :shared_with_batch, :integer
  end
end
