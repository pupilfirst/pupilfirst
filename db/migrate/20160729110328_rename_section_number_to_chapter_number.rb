class RenameSectionNumberToChapterNumber < ActiveRecord::Migration[4.2]
  def change
    rename_column :module_chapters, :section_number, :chapter_number
  end
end
