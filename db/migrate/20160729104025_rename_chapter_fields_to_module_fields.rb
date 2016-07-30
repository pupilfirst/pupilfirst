class RenameChapterFieldsToModuleFields < ActiveRecord::Migration
  def change
    rename_column :course_modules, :chapter_number, :module_number
    rename_column :chapter_sections, :course_chapter_id, :course_module_id
    rename_column :quiz_attempts, :course_chapter_id, :course_module_id
    rename_column :quiz_questions, :course_chapter_id, :course_module_id
  end
end
