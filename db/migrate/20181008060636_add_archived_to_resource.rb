class AddArchivedToResource < ActiveRecord::Migration[5.1]
  def change
    add_column :resources, :archived, :boolean, default: false
    add_index :resources, :archived
  end
end
