class RemoveSortIndexAndTargetFromContentBlocks < ActiveRecord::Migration[5.2]
  def change
    remove_column :content_blocks, :sort_index
    remove_column :content_blocks, :target_id
  end
end
