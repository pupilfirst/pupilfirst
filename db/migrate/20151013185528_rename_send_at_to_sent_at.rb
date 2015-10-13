class RenameSendAtToSentAt < ActiveRecord::Migration
  def change
    rename_column :startup_feedback, :send_at, :sent_at
  end
end
