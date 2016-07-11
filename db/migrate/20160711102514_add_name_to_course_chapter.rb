class AddNameToCourseChapter < ActiveRecord::Migration
  def change
    add_column :course_chapters, :name, :string
  end
end
