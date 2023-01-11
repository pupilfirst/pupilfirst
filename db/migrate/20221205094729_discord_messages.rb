class DiscordMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :discord_messages do |t|
      t.string :author_uuid, null: false, index: true
      t.string :channel_uuid, index: true
      t.string :message_uuid, null: false, unique: true
      t.string :server_uuid, index: true, null: false
      t.string :content
      t.datetime :timestamp
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
