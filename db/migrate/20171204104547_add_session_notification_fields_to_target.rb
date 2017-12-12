class AddSessionNotificationFieldsToTarget < ActiveRecord::Migration[5.1]
  def change
    add_column :targets, :google_calendar_event_id, :string
    add_column :targets, :feedback_asked_at, :datetime
    add_column :targets, :slack_reminders_sent_at, :datetime
  end
end
