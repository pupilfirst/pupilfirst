class ChangeEmailToBeCitextInUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :email, :citext
  end
end
