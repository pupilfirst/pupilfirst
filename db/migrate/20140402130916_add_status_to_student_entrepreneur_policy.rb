class AddStatusToStudentEntrepreneurPolicy < ActiveRecord::Migration
  def change
    add_column :student_entrepreneur_policies, :status, :boolean
  end
end
