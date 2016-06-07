class RenameNameToThemeInBatch < ActiveRecord::Migration
  def change
    rename_column :batches, :name, :theme
  end
end
