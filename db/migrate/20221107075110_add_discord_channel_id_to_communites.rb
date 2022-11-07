class AddDiscordChannelIdToCommunites < ActiveRecord::Migration[6.1]
  def change
    add_column :communities, :discord_channel_id, :string, null: true
  end
end
