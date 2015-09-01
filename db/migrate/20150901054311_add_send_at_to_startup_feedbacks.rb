class AddSendAtToStartupFeedbacks < ActiveRecord::Migration
  def change
    add_column :startup_feedbacks, :send_at, :datetime
  end
end
