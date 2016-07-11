class CreateCourseChapters < ActiveRecord::Migration
  def change
    create_table :course_chapters do |t|

      t.timestamps null: false
    end
  end
end
