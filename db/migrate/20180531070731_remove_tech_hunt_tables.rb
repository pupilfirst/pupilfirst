class RemoveTechHuntTables < ActiveRecord::Migration[5.1]
  def up
    drop_table :players
    drop_table :hunt_answers
  end

  # Copied from schema.rb
  def down
    create_table "hunt_answers", force: :cascade do |t|
      t.integer "stage"
      t.string "answer"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "players", force: :cascade do |t|
      t.string "name"
      t.string "phone"
      t.bigint "college_id"
      t.string "college_text"
      t.integer "stage", default: 0
      t.bigint "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "showcase_link"
      t.integer "attempts", default: 0
      t.index ["college_id"], name: "index_players_on_college_id"
      t.index ["user_id"], name: "index_players_on_user_id"
    end

    add_foreign_key "players", "colleges"
    add_foreign_key "players", "users"
  end
end
