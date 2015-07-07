class DropTableVersion < ActiveRecord::Migration
  def up
    drop_table :versions
  end

  def down
    create_table 'versions', force: :cascade do |t|
      t.string 'item_type', null: false
      t.integer 'item_id', null: false
      t.string 'event', null: false
      t.string 'whodunnit'
      t.text 'object'
      t.text 'object_changes'
      t.datetime 'created_at'
    end

    add_index 'versions', %w(item_type item_id), name: 'index_versions_on_item_type_and_item_id', using: :btree
  end
end
