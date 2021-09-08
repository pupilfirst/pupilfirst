class AddLoginTokenDigestToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :login_token_digest, :string
  end
end
