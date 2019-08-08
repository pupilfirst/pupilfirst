class CreateTargetContentVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :target_content_versions do |t|
      t.references :target, foreign_key: true
      t.integer :content_blocks, array: true

      t.timestamps
    end
  end
end
