class AddUnconfirmedPhoneToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :unconfirmed_phone, :string
  end
end
