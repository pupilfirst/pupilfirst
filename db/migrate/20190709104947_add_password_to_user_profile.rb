class AddPasswordToUserProfile < ActiveRecord::Migration[5.2]
  def up
    add_column :user_profiles, :password_digest, :string
  end

  def down
    remove_column :user_profiles, :password_digest
  end
end
