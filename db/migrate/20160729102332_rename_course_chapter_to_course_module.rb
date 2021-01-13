class RenameCourseChapterToCourseModule < ActiveRecord::Migration[4.2]
  def change
    rename_table :course_chapters, :course_modules
  end
end
