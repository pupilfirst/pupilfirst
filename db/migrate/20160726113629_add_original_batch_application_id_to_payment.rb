class AddOriginalBatchApplicationIdToPayment < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :original_batch_application_id, :integer
    add_index :payments, :original_batch_application_id
  end
end
