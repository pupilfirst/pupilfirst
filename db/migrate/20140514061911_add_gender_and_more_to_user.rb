class AddGenderAndMoreToUser < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string
    add_column :users, :phone, :string
    add_column :users, :communication_address, :text
  end
end
