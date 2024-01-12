class RemoveLevelFromStudents < ActiveRecord::Migration[7.0]
  def change
    remove_reference :students, :level, index: true
  end
end
