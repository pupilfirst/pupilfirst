class AddFieldsToCourseChapter < ActiveRecord::Migration
  def change
    add_column :course_chapters, :chapter_number, :integer
    add_column :course_chapters, :sections_count, :integer
  end
end
