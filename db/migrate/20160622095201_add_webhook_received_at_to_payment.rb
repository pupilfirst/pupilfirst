class AddWebhookReceivedAtToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :webhook_received_at, :datetime
  end
end
