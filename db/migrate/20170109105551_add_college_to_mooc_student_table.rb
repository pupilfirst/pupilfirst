class AddCollegeToMoocStudentTable < ActiveRecord::Migration[5.0]
  def change
    add_reference :mooc_students, :college, index: true
  end
end
