class AddDobToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :born_on, :date
  end
end
