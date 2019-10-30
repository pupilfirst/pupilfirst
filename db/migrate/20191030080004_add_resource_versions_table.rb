class AddResourceVersionsTable < ActiveRecord::Migration[6.0]
  def up
    create_table :resource_versions do |t|
      t.jsonb :value
      t.references :versionable, polymorphic: true, index: true
      t.datetime :archived_at

      t.timestamps
    end
  end

  def down
    drop_table :resource_versions
  end
end
