class AddTargetContentTables < ActiveRecord::Migration[5.2]
  def change
    create_table :content_blocks do |t|
      t.references :target, foreign_key: true

      t.string :block_type
      t.json :content
      t.integer :sort_index

      t.timestamps
    end

    add_index :content_blocks, :block_type
  end
end
