class CreateDiscordRolesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :discord_roles do |t|
      t.string :name
      t.string :discord_id, null: false
      t.references :school, null: false, foreign_key: true
      t.integer :position
      t.string :color_hex
      t.boolean :default, default: false
      t.jsonb :data

      t.timestamps
    end

    add_index :discord_roles, :discord_id, unique: true

    create_join_table :users,
                      :discord_roles,
                      table_name: "additional_user_discord_roles" do |t|
      t.index :discord_role_id

      t.index %i[user_id discord_role_id],
              unique: true,
              name: "index_user_discord_roles_on_user_id_and_discord_role_id"
    end
  end
end
