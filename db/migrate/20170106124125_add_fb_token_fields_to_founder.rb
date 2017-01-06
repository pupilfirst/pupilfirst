class AddFbTokenFieldsToFounder < ActiveRecord::Migration[5.0]
  def change
    add_column :founders, :fb_access_token, :string
    add_column :founders, :fb_token_expires_at, :datetime
  end
end
