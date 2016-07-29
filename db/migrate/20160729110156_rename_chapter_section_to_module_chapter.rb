class RenameChapterSectionToModuleChapter < ActiveRecord::Migration
  def change
    rename_table :chapter_sections, :module_chapters
  end
end
