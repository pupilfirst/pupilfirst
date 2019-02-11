class RemoveCourseFromResource < ActiveRecord::Migration[5.2]
  def change
    remove_column :resources, :course_id
  end
end
