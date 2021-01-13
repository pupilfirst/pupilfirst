class RemoveManagingDirectorFromUser < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :managing_director
  end

  def down
    add_column :users, :managing_director, :boolean, default: false
  end
end
