class AddWebhookTables < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :webhook_url, :string

    create_table :webhook_entries do |t|
      t.string :event, null: false
      t.string :status, null: false
      t.jsonb :payload, default: {}
      t.string :webhook_url, null: false
      t.references :school, null: false
      t.timestamps
    end
  end
end
