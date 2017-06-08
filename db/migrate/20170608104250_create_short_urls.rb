class CreateShortUrls < ActiveRecord::Migration[5.1]
  def change
    create_table :short_urls do |t|
      t.text :url, null: false # The full URL.
      t.string :key, null: false, limit: 10 # The unique, short, key.
      t.integer :uses, default: 0 # The number of times a URL was used.
      t.datetime :expires_at # Time after which the short link will not work.

      t.timestamps
    end

    add_index :short_urls, :url
    add_index :short_urls, :key, unique: :true
  end
end
