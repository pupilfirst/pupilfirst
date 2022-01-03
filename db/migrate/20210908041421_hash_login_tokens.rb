class HashLoginTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :login_token_digest, :string
    add_index :users, :login_token_digest, unique: true
    add_column :applicants, :login_token_digest, :string
    add_index :applicants, :login_token_digest, unique: true
    rename_column :users, :delete_account_token, :delete_account_token_digest
    remove_column :founders, :slack_access_token, :string
  end
end
