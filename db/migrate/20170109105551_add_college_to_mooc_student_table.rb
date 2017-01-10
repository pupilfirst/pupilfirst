class AddCollegeToMoocStudentTable < ActiveRecord::Migration[5.0]
  def change
    add_column :mooc_students, :college_id, :integer
  end
end
