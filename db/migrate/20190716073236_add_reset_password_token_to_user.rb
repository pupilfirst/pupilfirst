class AddResetPasswordTokenToUser < ActiveRecord::Migration[5.2]
  def up
    # Device Recoverable
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_index :users, :reset_password_token, :unique => true
  end

  def down
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
  end
end
