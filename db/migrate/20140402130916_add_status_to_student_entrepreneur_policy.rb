class AddStatusToStudentEntrepreneurPolicy < ActiveRecord::Migration[4.2]
  def change
    add_column :student_entrepreneur_policies, :status, :boolean
  end
end
