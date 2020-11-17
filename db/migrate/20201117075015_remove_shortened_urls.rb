class RemoveShortenedUrls < ActiveRecord::Migration[6.0]
  def up
    drop_table :shortened_urls
  end

  def down
    create_table :shortened_urls, id: :serial do |t|
      t.integer "owner_id"
      t.string "owner_type", limit: 20
      t.text "url", null: false
      t.string "unique_key", limit: 100, null: false
      t.integer "use_count", default: 0, null: false
      t.datetime "expires_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index %w[owner_id owner_type], name: "index_shortened_urls_on_owner_id_and_owner_type"
      t.index ["unique_key"], name: "index_shortened_urls_on_unique_key", unique: true
      t.index ["url"], name: "index_shortened_urls_on_url"
    end
  end
end
