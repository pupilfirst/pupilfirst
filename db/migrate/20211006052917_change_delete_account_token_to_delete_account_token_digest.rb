class ChangeDeleteAccountTokenToDeleteAccountTokenDigest < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :delete_account_token, :delete_account_token_digest
  end
end
