class AddNotificationSentToNews < ActiveRecord::Migration
  def change
    add_column :news, :notification_sent, :boolean
  end
end
