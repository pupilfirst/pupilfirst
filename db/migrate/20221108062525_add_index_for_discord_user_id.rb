class AddIndexForDiscordUserId < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :discord_user_id
    add_column :users, :discord_tag, :string
  end
end
