class AddLoginTokenDigestToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :login_token_digest, :string
    add_index :users, :login_token_digest, unique: true
  end
end
