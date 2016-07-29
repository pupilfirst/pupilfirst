class RenameCourseChapterToCourseModule < ActiveRecord::Migration
  def change
    rename_table :course_chapters, :course_modules
  end
end
