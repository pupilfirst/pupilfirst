class RenameChapterSectionToModuleChapter < ActiveRecord::Migration[4.2]
  def change
    rename_table :chapter_sections, :module_chapters
  end
end
