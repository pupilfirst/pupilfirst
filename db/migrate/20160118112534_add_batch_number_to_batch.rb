class AddBatchNumberToBatch < ActiveRecord::Migration[4.2]
  def change
    add_column :batches, :batch_number, :integer
  end
end
