class AddDeleteAccountTokenToUser < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :delete_account_token, :string
    add_column :users, :delete_account_sent_at, :datetime
    add_index :users, :delete_account_token, :unique => true
  end

  def down
    remove_column :users, :delete_account_token
    remove_column :users, :delete_account_sent_at
  end
end
