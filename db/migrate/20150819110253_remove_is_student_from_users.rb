class RemoveIsStudentFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :is_student, :boolean
  end
end
