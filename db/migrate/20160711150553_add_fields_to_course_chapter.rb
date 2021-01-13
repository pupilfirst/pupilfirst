class AddFieldsToCourseChapter < ActiveRecord::Migration[4.2]
  def change
    add_column :course_chapters, :chapter_number, :integer
    add_column :course_chapters, :sections_count, :integer
  end
end
