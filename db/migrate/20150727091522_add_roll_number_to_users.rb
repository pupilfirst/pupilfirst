class AddRollNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :roll_number, :string
  end
end
