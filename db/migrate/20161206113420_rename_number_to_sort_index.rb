class RenameNumberToSortIndex < ActiveRecord::Migration[5.0]
  def change
    rename_column :target_groups, :number, :sort_index
  end
end
