class AddNotificationSentToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :notification_sent, :boolean
  end
end
