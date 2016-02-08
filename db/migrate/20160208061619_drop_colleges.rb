class DropColleges < ActiveRecord::Migration
  def self.up
    drop_table :colleges
  end

  def self.down
    create_table :colleges do |t|
      t.string   "name"
      t.string   "university"
      t.string   "city"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
