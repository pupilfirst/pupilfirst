class RemoveIndexOnEmailFromUser < ActiveRecord::Migration
  def up
    remove_index :users, column: 'email'
  end

  def down
    add_index :users, :email, unique: true
  end
end
