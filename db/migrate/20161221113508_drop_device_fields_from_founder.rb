class DropDeviceFieldsFromFounder < ActiveRecord::Migration[5.0]
  def change
    remove_column :founders, :encrypted_password, :string
    remove_column :founders, :reset_password_token, :string
    remove_column :founders, :reset_password_sent_at, :datetime
    remove_column :founders, :remember_created_at, :datetime
    remove_column :founders, :sign_in_count, :integer
    remove_column :founders, :current_sign_in_at, :datetime
    remove_column :founders, :last_sign_in_at, :datetime
    remove_column :founders, :current_sign_in_ip, :string
    remove_column :founders, :last_sign_in_ip, :string
    remove_column :founders, :confirmation_token, :string
    remove_column :founders, :confirmed_at, :datetime
    remove_column :founders, :confirmation_sent_at, :datetime
    remove_column :founders, :unconfirmed_email, :string
  end
end
