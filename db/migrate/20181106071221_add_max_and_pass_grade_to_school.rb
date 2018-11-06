class AddMaxAndPassGradeToSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :max_grade, :integer
    add_column :schools, :pass_grade, :integer
  end
end
