class AddWebhookReceivedAtToPayment < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :webhook_received_at, :datetime
  end
end
