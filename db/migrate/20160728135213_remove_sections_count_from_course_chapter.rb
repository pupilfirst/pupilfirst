class RemoveSectionsCountFromCourseChapter < ActiveRecord::Migration[4.2]
  def change
    remove_column :course_chapters, :sections_count, :integer
  end
end
