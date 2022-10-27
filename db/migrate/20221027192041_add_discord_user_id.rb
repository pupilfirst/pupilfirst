class AddDiscordUserId < ActiveRecord::Migration[6.1]
  def change
    add_column :users,
               :discord_user_id,
               :string,
               null: true,
               default: nil,
               index: true
  end
end
