class AddNotificationSentToEvents < ActiveRecord::Migration
  def change
    add_column :events, :notification_sent, :boolean
  end
end
