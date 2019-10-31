class CreateResourceVersionsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_versions do |t|
      t.jsonb :value
      t.references :versionable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
