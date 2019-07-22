class AddRegisteredUsers < ActiveRecord::Migration[5.2]
  def up
    create_table :registered_users do |t|
      t.string :email
      t.string :login_token
      t.datetime :login_token_sent_at
      t.references :course, foreign_key: true
      t.timestamps
    end
    add_column :courses, :enable_public_signup, :boolean, default: false
    add_index :registered_users, :login_token, :unique => true
  end

  def down
    drop_table :registered_users
  end
end
