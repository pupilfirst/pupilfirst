class RemoveUsernameFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :username, :string
  end
end
