class CreateCourseReports < ActiveRecord::Migration[5.2]
  def change
    create_table :course_reports do |t|
      t.text :csv
      t.references :user, foreign_key: true
      t.references :course, foreign_key: true
      t.string :token
      t.datetime :prepared_at

      t.timestamps
    end

    add_index :course_reports, :token, unique: true
  end
end
