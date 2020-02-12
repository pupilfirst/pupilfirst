class DropContentVersions < ActiveRecord::Migration[6.0]
  def up
    drop_table :content_versions
  end

  def down
    create_table :content_versions do |t|
      t.references :target, foreign_key: true
      t.references :content_block, foreign_key: true
      t.date :version_on, index: true
      t.integer :sort_index
    end
  end
end
