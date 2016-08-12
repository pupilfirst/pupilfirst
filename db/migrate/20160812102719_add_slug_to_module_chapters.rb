class AddSlugToModuleChapters < ActiveRecord::Migration
  def change
    add_column :module_chapters, :slug, :string
    add_index :module_chapters, :slug
  end
end
