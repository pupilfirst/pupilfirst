class AddPinToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :pin, :string
  end
end
