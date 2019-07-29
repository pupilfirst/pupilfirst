class CreateCourseAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :course_authors do |t|
      t.references :user, foreign_key: true
      t.references :course, foreign_key: true
      t.boolean :exited

      t.timestamps
    end
  end
end

