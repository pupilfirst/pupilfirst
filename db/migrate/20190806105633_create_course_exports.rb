class CreateCourseExports < ActiveRecord::Migration[5.2]
  def change
    create_table :course_exports do |t|
      t.references :user, foreign_key: true
      t.references :course, foreign_key: true

      t.timestamps
    end
  end
end
