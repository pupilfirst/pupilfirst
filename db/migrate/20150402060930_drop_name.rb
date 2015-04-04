class DropName < ActiveRecord::Migration
  def up
    drop_table :names
  end

  def down
    # Backup the schema.
    create_table 'names', force: :cascade do |t|
      t.string 'first_name'
      t.string 'last_name'
      t.string 'middle_name'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.string 'salutation'
    end
  end
end
