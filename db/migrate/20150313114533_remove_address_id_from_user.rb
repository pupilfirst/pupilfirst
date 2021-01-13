class RemoveAddressIdFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :address_id, :integer
  end
end
