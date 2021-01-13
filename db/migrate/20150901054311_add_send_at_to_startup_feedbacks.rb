class AddSendAtToStartupFeedbacks < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_feedbacks, :send_at, :datetime
  end
end
