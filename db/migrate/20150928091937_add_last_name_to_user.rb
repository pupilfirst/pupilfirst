class AddLastNameToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_name, :string, default: ''
  end
end
