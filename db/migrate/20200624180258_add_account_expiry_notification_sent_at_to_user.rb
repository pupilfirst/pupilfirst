class AddAccountExpiryNotificationSentAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :account_expiry_notification_sent_at, :datetime
  end
end
