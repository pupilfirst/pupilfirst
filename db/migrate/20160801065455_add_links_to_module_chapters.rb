class AddLinksToModuleChapters < ActiveRecord::Migration[4.2]
  def change
    add_column :module_chapters, :links, :text
  end
end
