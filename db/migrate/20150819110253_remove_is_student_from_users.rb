class RemoveIsStudentFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :is_student, :boolean
  end
end
