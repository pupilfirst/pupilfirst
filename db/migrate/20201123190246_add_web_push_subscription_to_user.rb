class AddWebPushSubscriptionToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :web_push_subscription, :jsonb, default: {}
  end
end
