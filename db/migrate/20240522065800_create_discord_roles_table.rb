class CreateDiscordRolesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :discord_roles do |t|
      t.string :name
      t.string :discord_id, null: false
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end

    add_index :discord_roles, :discord_id

    create_join_table :users,
                      :discord_roles,
                      table_name: "user_discord_roles" do |t|
      t.index :user_id
      t.index :discord_role_id
    end
  end
end
