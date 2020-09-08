class AddApiTokenDigestToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :api_token_digest, :string
    add_index :users, :api_token_digest, unique: true
  end
end
