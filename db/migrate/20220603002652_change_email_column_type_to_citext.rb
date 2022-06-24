class ChangeEmailColumnTypeToCitext < ActiveRecord::Migration[6.1]
  def change
    change_column :applicants, :email, :citext
    change_column :admin_users, :email, :citext
    change_column :users, :email, :citext
  end
end
