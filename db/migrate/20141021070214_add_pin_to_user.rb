class AddPinToUser < ActiveRecord::Migration
  def change
    add_column :users, :pin, :string
  end
end
