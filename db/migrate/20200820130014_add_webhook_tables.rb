class AddWebhookTables < ActiveRecord::Migration[6.0]
  def change
    create_table :webhook_endpoints do |t|
      t.references :course, null: false, index: { unique: true }, foreign_key: true
      t.string :webhook_url, null: false
      t.boolean :active, default: true
      t.jsonb :events, array: true
    end

    create_table :webhook_deliveries do |t|
      t.string :event, null: false
      t.string :status
      t.jsonb :response_headers
      t.text :response_body
      t.jsonb :payload, default: {}
      t.string :webhook_url, null: false
      t.datetime :sent_at
      t.string :error_class
      t.references :course, null: false
      t.timestamps
    end
  end
end
