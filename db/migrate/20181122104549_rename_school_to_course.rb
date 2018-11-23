class RenameSchoolToCourse < ActiveRecord::Migration[5.2]
  def change
    rename_table :schools, :courses
    rename_column :levels, :school_id, :course_id
  end
end
