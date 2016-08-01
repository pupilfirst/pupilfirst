class AddLinksToModuleChapters < ActiveRecord::Migration
  def change
    add_column :module_chapters, :links, :text
  end
end
