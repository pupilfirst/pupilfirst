class RenameSendAtToSentAt < ActiveRecord::Migration[4.2]
  def change
    rename_column :startup_feedback, :send_at, :sent_at
  end
end
