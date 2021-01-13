class AddRollNumberToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :roll_number, :string
  end
end
