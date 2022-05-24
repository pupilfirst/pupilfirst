class ChangeEmailToBeCitextInAdminUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :admin_users, :email, :citext
  end
end
