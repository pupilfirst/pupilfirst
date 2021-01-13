class AddNameToCourseChapter < ActiveRecord::Migration[4.2]
  def change
    add_column :course_chapters, :name, :string
  end
end
