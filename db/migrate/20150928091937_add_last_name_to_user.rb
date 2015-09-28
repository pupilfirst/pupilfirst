class AddLastNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_name, :string, default: ''
  end
end
