class DropTableBanks < ActiveRecord::Migration
  def up
    drop_table :banks
  end

  def down
    create_table "banks" do |t|
      t.string  "name"
      t.boolean "is_joint"
      t.integer "startup_id"
    end

    add_index "banks", ["startup_id"], name: "index_banks_on_startup_id", using: :btree
  end
end
