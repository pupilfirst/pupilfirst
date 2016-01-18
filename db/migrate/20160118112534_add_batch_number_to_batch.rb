class AddBatchNumberToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :batch_number, :integer
  end
end
