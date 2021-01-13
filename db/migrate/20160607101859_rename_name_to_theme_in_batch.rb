class RenameNameToThemeInBatch < ActiveRecord::Migration[4.2]
  def change
    rename_column :batches, :name, :theme
  end
end
