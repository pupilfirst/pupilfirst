class RenameSectionNumberToChapterNumber < ActiveRecord::Migration
  def change
    rename_column :module_chapters, :section_number, :chapter_number
  end
end
