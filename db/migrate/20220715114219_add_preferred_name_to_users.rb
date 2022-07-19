class AddPreferredNameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :preferred_name, :string
  end
end
