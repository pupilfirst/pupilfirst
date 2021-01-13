class AddStartupToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :startup_id, :integer
  end
end
