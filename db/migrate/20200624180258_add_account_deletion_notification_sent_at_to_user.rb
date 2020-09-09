class AddAccountDeletionNotificationSentAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :account_deletion_notification_sent_at, :datetime
  end
end
