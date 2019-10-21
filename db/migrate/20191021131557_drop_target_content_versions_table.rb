class DropTargetContentVersionsTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :target_content_versions
  end

  def down
    create_table :target_content_versions do |t|
      t.references :target, foreign_key: true
      t.integer :content_blocks, array: true

      t.timestamps
    end
  end
end
