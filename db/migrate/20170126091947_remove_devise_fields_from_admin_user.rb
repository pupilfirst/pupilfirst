class RemoveDeviseFieldsFromAdminUser < ActiveRecord::Migration[5.0]
  def change
    remove_column :admin_users, :encrypted_password, :string, :null => false, :default => ''
    remove_column :admin_users, :reset_password_token, :string
    remove_column :admin_users, :reset_password_sent_at, :datetime
    remove_column :admin_users, :remember_created_at, :datetime
    remove_column :admin_users, :sign_in_count, :integer, :default => 0, :null => false
    remove_column :admin_users, :current_sign_in_at, :datetime
    remove_column :admin_users, :last_sign_in_at, :datetime
    remove_column :admin_users, :current_sign_in_ip, :string
    remove_column :admin_users, :last_sign_in_ip, :string
  end
end
