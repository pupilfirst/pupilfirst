class AddIncludeInactiveStudentsToCourseExport < ActiveRecord::Migration[6.0]
  def change
    add_column :course_exports,
               :include_inactive_students,
               :boolean,
               default: false
  end
end
