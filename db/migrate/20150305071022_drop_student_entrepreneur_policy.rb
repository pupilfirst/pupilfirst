class DropStudentEntrepreneurPolicy < ActiveRecord::Migration[4.2]
  def change
    drop_table :student_entrepreneur_policies
  end
end
