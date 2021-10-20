class ChangeResetPasswordTokenToResetPasswordTokenDigest < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :reset_password_token, :reset_password_token_digest
  end
end
