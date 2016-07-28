class RemoveSectionsCountFromCourseChapter < ActiveRecord::Migration
  def change
    remove_column :course_chapters, :sections_count, :integer
  end
end
