class AddWebPushSubscriptionToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :webpush_subscription, :jsonb, default: {}
  end
end
