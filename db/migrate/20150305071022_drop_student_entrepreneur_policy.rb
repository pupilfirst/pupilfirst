class DropStudentEntrepreneurPolicy < ActiveRecord::Migration
  def change
    drop_table :student_entrepreneur_policies
  end
end
