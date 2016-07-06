class RemovePhoneFromBatchApplication < ActiveRecord::Migration
  def change
    remove_column :batch_applications, :phone, :string
  end
end
