class RemoveColumnsRelatedToFacebookShare < ActiveRecord::Migration[5.2]
  def change
    remove_column :founders, :fb_access_token
    remove_column :founders, :fb_token_expires_at
    remove_column :timeline_events, :share_on_facebook
  end
end
