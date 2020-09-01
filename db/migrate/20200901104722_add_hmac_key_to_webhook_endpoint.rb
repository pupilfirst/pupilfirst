class AddHmacKeyToWebhookEndpoint < ActiveRecord::Migration[6.0]
  class WebhookEndpoint < ApplicationRecord
  end

  def change
    add_column :webhook_endpoints, :hmac_key, :string

    WebhookEndpoint.all.each do |endpoint|
      endpoint.update!(hmac_key: SecureRandom.base64)
    end

    change_column_null :webhook_endpoints, :hmac_key, false
  end
end
