class CreateFacultyEnrollmentTables < ActiveRecord::Migration[5.2]
  def change
    create_table :faculty_course_enrollments do |t|
      t.references :faculty, foreign_key: true
      t.references :course, foreign_key: true, index: false

      t.timestamps
    end

    add_index :faculty_course_enrollments, %i[course_id faculty_id], unique: true

    create_table :faculty_startup_enrollments do |t|
      t.references :faculty, foreign_key: true
      t.references :startup, foreign_key: true, index: false

      t.timestamps
    end

    add_index :faculty_startup_enrollments, %i[startup_id faculty_id], unique: true
  end
end
