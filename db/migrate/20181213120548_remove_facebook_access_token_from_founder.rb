class RemoveFacebookAccessTokenFromFounder < ActiveRecord::Migration[5.2]
  def up
    remove_column :founders, :fb_access_token
    remove_column :founders, :fb_token_expires_at
  end

  def down
    add_column :founders, :fb_access_token, :string
    add_column :founders, :fb_token_expires_at, :datetime
  end
end
