class AddGradeLabelsToSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :grade_labels, :json
  end
end
