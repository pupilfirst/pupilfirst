class RemoveGradeColumnsFromCourse < ActiveRecord::Migration[6.0]
  def change
    remove_column :courses, :max_grade, :integer
    remove_column :courses, :pass_grade, :integer
    remove_column :courses, :grade_labels, :json
  end
end
