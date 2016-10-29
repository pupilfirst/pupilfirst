class AddEncryptedPasswordToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :encrypted_password, :string, default: "", null: false
  end
end
