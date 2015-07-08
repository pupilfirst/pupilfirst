class DropTableEvents < ActiveRecord::Migration
  def up
    drop_table :events
  end

  def down
    create_table "events" do |t|
      t.string "title"
      t.text "description"
      t.datetime "start_at"
      t.datetime "end_at"
      t.string "location"
      t.boolean "featured"
      t.integer "category_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "picture"
      t.integer "user_id"
      t.boolean "notification_sent"
      t.boolean "approved", default: false
      t.string "posters_name"
      t.string "posters_email"
      t.string "posters_phone_number"
      t.boolean "approval_notification_sent", default: false
    end

    add_index "events", ["category_id"], name: "index_events_on_category_id", using: :btree
    add_index "events", ["location"], name: "index_events_on_location", using: :btree
    add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree
  end
end
