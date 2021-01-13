class AddNotificationSentToNews < ActiveRecord::Migration[4.2]
  def change
    add_column :news, :notification_sent, :boolean
  end
end
