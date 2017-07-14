class RemoveUniversitiesTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :universities
  end

  def down
    create_table 'universities', id: :serial, force: :cascade do |t|
      t.string 'name'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.string 'location'
    end
  end
end
