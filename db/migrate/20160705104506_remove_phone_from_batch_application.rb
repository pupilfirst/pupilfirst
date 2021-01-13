class RemovePhoneFromBatchApplication < ActiveRecord::Migration[4.2]
  def change
    remove_column :batch_applications, :phone, :string
  end
end
