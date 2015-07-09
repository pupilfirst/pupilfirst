class DropTablesForActsAsTaggable < ActiveRecord::Migration
  def up
    drop_table :taggings
    drop_table :tags
  end

  def down
    create_table "taggings" do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "context",       limit: 128
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

    create_table "tags" do |t|
      t.string  "name"
      t.integer "taggings_count", default: 0
    end

    add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end
end
