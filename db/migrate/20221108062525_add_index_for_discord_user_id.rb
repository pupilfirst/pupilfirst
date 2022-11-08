class AddIndexForDiscordUserId < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :discord_user_id, unique: true
    add_column :users, :discord_discriminator, :string
  end
end
